# == Class: neutron::agents:f5-bigip-lbaas:
#
# Setups Neutron Load Balancing agent.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) Ensure state for package. Defaults to 'present'.
#
# [*enabled*]
#   (optional) Enable state for service. Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*debug*]
#   (optional) Show debugging output in log. Defaults to false.
#
# [*interface_driver*]
#   (optional) Defaults to 'neutron.agent.linux.interface.OVSInterfaceDriver'.
#
# [*device_driver*]
#   (optional) Defaults to 'neutron.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver'.
#
# [*use_namespaces*]
#   (optional) Allow overlapping IP (Must have kernel build with
#   CONFIG_NET_NS=y and iproute2 package that supports namespaces).
#   Defaults to true.
#
# [*user_group*]
#   (optional) The user group. Defaults to nogroup.
#
# [*manage_haproxy_package*]
#   (optional) Whether to manage the haproxy package.
#   Disable this if you are using the puppetlabs-haproxy module
#   Defaults to true
#
class neutron::agents::f5-bigip-lbaas (
  $neutron_config     = {},
  $package_ensure         = present,
  $enabled                = true,
  $manage_service         = true,
  $debug                  = false,
  #$interface_driver       = 'neutron.agent.linux.interface.OVSInterfaceDriver',
  #$device_driver          = 'neutron.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
  #$use_namespaces         = true,
  #$user_group             = 'nogroup',
  #$manage_haproxy_package = true,
  $agent_cfg               = '',
) {

  include neutron::params

  #Neutron_config<||>             ~> Service['neutron-f5-bigip-lbaas-service']
  #Neutron_f5_bigip_lbaas_agent_config<||> ~> Service['neutron-f5-bigip-lbaas-service']

  Anchor<| title=='neutron-server-done' |> ->
  anchor {'neutron-f5-bigip-lbaas': }
  Service<| title=='neutron-server' |> -> Anchor['neutron-f5-bigip-lbaas']


  ##FIXME
  # Service<| title == 'neutron-server' |> -> Service<| title == 'neutron-f5-bigip-lbaas-service' |>
  # Service['neutron-f5-bigip-lbaas-service'] ~> Service<| title == 'neutron-server' |>

  # The LBaaS agent loads both neutron.ini and its own file.
  # This only lists config specific to the agent.  neutron.ini supplies
  # the rest.
  #neutron_lbaas_agent_config {
  #  'DEFAULT/debug':              value => $debug;
  #  'DEFAULT/interface_driver':   value => $interface_driver;
  #  'DEFAULT/device_driver':      value => $device_driver;
  #  'DEFAULT/use_namespaces':     value => $use_namespaces;
  #  'haproxy/user_group':         value => $user_group;
  #}

  Neutron_config <| |> -> Neutron_f5_bigip_lbaas_agent_config <| |>
  Neutron_f5_bigip_lbaas_agent_config <| |> -> Service['neutron-f5-bigip-lbaas-service']

  ##??? should fix values
  neutron_f5_bigip_lbaas_agent_config {
    'DEFAULT/icontrol_hostname':              value => $agent_cfg['icontrol_hostname'];
    'DEFAULT/icontrol_username':              value => $agent_cfg['icontrol_username'];
    'DEFAULT/icontrol_password':              value => $agent_cfg['icontrol_password'];
    'DEFAULT/f5_ha_type':                     value => $agent_cfg['ha_type'];
    'DEFAULT/f5_global_routed_mode':          value => $agent_cfg['global_routed_mode'];
    'DEFAULT/f5_snat_mode':                   value => $agent_cfg['snat_mode'];
    'DEFAULT/f5_external_physical_mappings':  value => 'physnet2:1.2:True,default:1.1:True';
    'DEFAULT/f5_vtep_folder':                 value => 'None';
    'DEFAULT/f5_vtep_selfip_name':            value => 'None';
  }

  Anchor['neutron-f5-bigip-lbaas'] ->
    Neutron_l3_agent_config <| |> ->
          Service<| title=='neutron-f5-bigip-lbaas' |>  ->
              Anchor['neutron-f5-bigip-lbaas-done']

  #if $::neutron::params::lbaas_agent_package {
  #if $::fuel_settings['f5']['use_lbaas'] {
    Package['neutron']            -> Package['neutron-f5-bigip-lbaas-agent']
    ###???
    Package['neutron-f5-bigip-lbaas-agent'] -> Neutron_config<||>
    Package['neutron-f5-bigip-lbaas-agent'] -> Neutron_f5_bigip_lbaas_agent_config<||>
    package { 'neutron-f5-bigip-lbaas-agent':
      #ensure  => $package_ensure,
      ##FIXME
      #name    => $::neutron::params::lbaas_agent_package,
      ensure  => 'present',
      name    => 'f5-bigip-lbaas-driver-agent',
    }
  #}

  #File['f5-service-provider.sh'] -> Exec['f5-bigip-lbaas-agent-service_provider']

  file {'f5-service-provider.sh':
    path => "/tmp/f5-service-provider.sh",
    mode => '0755',
    owner => root,
    group => root,
    source => "puppet:///modules/neutron/f5-service-provider.sh",
  }

  neutron_config {'DEFAULT/service_plugins':
    value => 'neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,neutron.services.firewall.fwaas_plugin.FirewallPlugin,neutron.services.metering.metering_plugin.MeteringPlugin,neutron.services.loadbalancer.plugin.LoadBalancerPlugin';
  } ~> Service['neutron-server']
  
  #Exec['f5-bigip-lbaas-agent-service_provider_not_exists'] -> Exec['f5-bigip-lbaas-agent-service_provider_exists'] ~> Service['neutron-server']
  ## if service_provider=LOADBALANCER:F5 exists in /etc/neutron/neutron.conf change it's value
  exec { "f5-bigip-lbaas-agent-service_provider_exists":
    command => "sed -i -e 's/^service_provider=LOADBALANCER:F5.*/service_provider=LOADBALANCER:F5:neutron.services.loadbalancer.drivers.f5.plugin_driver.F5PluginDriver/' /etc/neutron/neutron.conf",
    path    => "/usr/bin:/usr/sbin:/bin",
    unless  => "bash /tmp/f5-service-provider.sh",
    require => File['f5-service-provider.sh'],
  }
  
  ## add service_provider=LOADBALANCER:F5 if it isn't exist in /etc/neutron/neutron.conf
  ## FIXME: dumb `echo` isn't safe. Should be changed
  exec { "f5-bigip-lbaas-agent-service_provider_not_exists":
    command => "echo 'service_provider=LOADBALANCER:F5:neutron.services.loadbalancer.drivers.f5.plugin_driver.F5PluginDriver' >> /etc/neutron/neutron.conf",
    path    => "/usr/bin:/usr/sbin:/bin",
    onlyif  => "bash /tmp/f5-service-provider.sh",
    require => File['f5-service-provider.sh'],
  }

#  if $service_provider == 'pacemaker' {
  # OCF script for pacemaker
  # and his dependences
  file {'f5-bigip-lbaas-ocf-script':
    path => "/usr/lib/ocf/resource.d/mirantis/neutron-agent-f5",
    mode => '0755',
    owner => root,
    group => root,
    source => "puppet:///modules/neutron/ocf/neutron-agent-f5",
  }

    Anchor['neutron-f5-bigip-lbaas'] -> File['f5-bigip-lbaas-ocf-script']
    Neutron_l3_agent_config <| |> -> File['f5-bigip-lbaas-ocf-script']
    Package['pacemaker'] -> File['f5-bigip-lbaas-ocf-script']
    File<| title == 'ocf-mirantis-path' |> -> File['f5-bigip-lbaas-ocf-script']
#    File<| title == 'q-agent-cleanup.py'|> -> File['neutron-l3-agent-ocf']
    Package['neutron-f5-bigip-lbaas-agent'] -> File['f5-bigip-lbaas-ocf-script']

    if $primary_controller {
      cs_resource { "p_${::neutron::params::f5_bigip_lbaas_agent_service}":
        ensure          => present,
        primitive_class => 'ocf',
        provided_by     => 'mirantis',
        primitive_type  => 'neutron-agent-f5',
        parameters      => {
          'debug'       => $debug,
          'syslog'      => $::use_syslog,
          'os_auth_url' => $neutron_config['keystone']['auth_url'],
          'tenant'      => $neutron_config['keystone']['admin_tenant_name'],
          'username'    => $neutron_config['keystone']['admin_user'],
          'password'    => $neutron_config['keystone']['admin_password'],
        },
        metadata        => { 'resource-stickiness' => '1' },
        operations      => {
          'monitor'  => {
            'interval' => '20',
            'timeout'  => '10'
          }
          ,
          'start'    => {
            'timeout' => '60'
          }
          ,
          'stop'     => {
            'timeout' => '60'
          }
        },
      }
      Cs_resource["p_${::neutron::params::f5_bigip_lbaas_agent_service}"] ->
      cs_order { 'f5_bigip_lbaas-after-ovs':
        ensure => present,
        first  => "clone_p_${::neutron::params::ovs_agent_service}",
        second => "p_${::neutron::params::f5_bigip_lbaas_agent_service}",
        score  => 'INFINITY',
      } -> Service['neutron-f5-bigip-lbaas-service']

      Cs_resource["p_${::neutron::params::f5_bigip_lbaas_agent_service}"] ->
      cs_order { 'f5_bigip_lbaas-after-metadata':
        ensure => present,
        first  => "clone_p_neutron-metadata-agent",
        second => "p_${::neutron::params::f5_bigip_lbaas_agent_service}",
        score  => 'INFINITY',
      } -> Service['neutron-f5-bigip-lbaas-service']

      ## start DHCP and L3 agents on different controllers if it's possible
      #Cs_resource["p_${::neutron::params::l3_agent_service}"] ->
      #cs_colocation { 'dhcp-without-l3':
      #  ensure     => present,
      #  score      => '-100',
      #  primitives => [
      #    "p_${::neutron::params::dhcp_agent_service}",
      #    "p_${::neutron::params::l3_agent_service}"
      #  ],
      #}

      Service['neutron-f5-bigip-lbaas-init_stopped'] ->
        Cs_resource["p_${::neutron::params::f5_bigip_lbaas_agent_service}"] ->
           Service['neutron-f5-bigip-lbaas-service']

      File['f5-bigip-lbaas-ocf-script'] -> Cs_resource["p_${::neutron::params::f5_bigip_lbaas_agent_service}"]
    } else {

      File['f5-bigip-lbaas-ocf-script'] -> Service['neutron-f5-bigip-lbaas-service']
    }

    Anchor<| title == 'neutron-ovs-agent-done' |> -> Anchor<| title=='neutron-f5-bigip-lbaas' |>
    Anchor<| title == 'neutron-metadata-agent-done' |> -> Anchor<| title=='neutron-f5-bigip-lbaas' |>
    Anchor<| title == 'neutron-dhcp-agent-done' |> -> Anchor<| title=='neutron-f5-bigip-lbaas' |>
#    if !defined(Package['lsof']) {
#      package { 'lsof': }
#    }
#    Package['lsof'] -> File['neutron-l3-agent-ocf']

    # Ensure service is stopped  and disabled by upstart/init/etc.
    Anchor['neutron-f5-bigip-lbaas'] ->
      Service['neutron-f5-bigip-lbaas-service-init_stopped'] ->
        Service['neutron-f5-bigip-lbaas-service'] ->
          Anchor['neutron-f5-bigip-lbaas-done']

    service { 'neutron-f5-bigip-lbaas-service-init_stopped':
      name       => "${::neutron::params::f5_bigip_lbaas_agent_service}",
      enable     => false,
      ensure     => stopped,
      hasstatus  => true,
      hasrestart => true,
      provider   => 'generic',
    }

    service { 'neutron-f5-bigip-lbaas-service':
      name       => "p_${::neutron::params::f5_bigip_lbaas_agent_service}",
      enable     => true,
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      provider   => "pacemaker",
    }

}
# else {
#    # No pacemaker use
#    Neutron_config <| |> ~> Service['neutron-l3']
#    Neutron_l3_agent_config <| |> ~> Service['neutron-l3']
#    service { 'neutron-l3':
#      name       => $::neutron::params::l3_agent_service,
#      enable     => true,
#      ensure     => running,
#      hasstatus  => true,
#      hasrestart => true,
#      provider   => $::neutron::params::service_provider,
#    }
#  }

#  if $manage_service {
#    if $enabled {
#      $service_ensure = 'running'
#    } else {
#      $service_ensure = 'stopped'
#    }
#  }

#  service { 'neutron-f5-bigip-lbaas-service':
#    ensure  => $service_ensure,
#    #name    => $::neutron::params::lbaas_agent_service,
#    name    => 'f5-bigip-lbaas-agent',
#    enable  => $enabled,
#    require => Class['neutron'],
#  }

#  anchor {'neutron-l3-cellar': }
#  Anchor['neutron-l3-cellar'] -> Anchor['neutron-l3-done']
  anchor {'neutron-f5-bigip-lbaas-done': }
  Anchor['neutron-f5-bigip-lbaas'] -> Anchor['neutron-f5-bigip-lbaas-done']
  Package<| title == 'neutron-f5-bigip-lbaas-agent'|> ~> Service<| title == 'neutron-f5-bigip-lbaas-service'|>
#  if !defined(Service['neutron-l3']) {
#    notify{ "Module ${module_name} cannot notify service neutron-l3 on package update": }
#  }


}
