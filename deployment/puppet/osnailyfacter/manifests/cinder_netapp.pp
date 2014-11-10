#$fuel_settings = parseyaml($astute_settings_yaml)
$netapp_hash = $fuel_settings['netapp']

class osnailyfacter::cinder_netapp (
  $netapp_cfg	= {}
){

	cinder::backend::netapp {'netapp':
	   netapp_login => $netapp_cfg['netapp_login'],
	   netapp_password => $netapp_cfg['netapp_password'],
	   netapp_server_hostname => $netapp_cfg['netapp_server_hostname'],
	   netapp_server_port => $netapp_cfg['netapp_server_port'],
	   netapp_storage_family => $netapp_cfg['netapp_storage_family'],
	   netapp_storage_protocol => $netapp_cfg['netapp_storage_protocol'],
	   netapp_volume_list => $netapp_cfg['netapp_volume_list'],
	   netapp_vserver => $netapp_cfg['netapp_vserver'],
	   volume_backend_name => $netapp_cfg['volume_backend_name'],
	#  netapp_size_multiplier => $netapp_cfg['netapp_size_multiplier'],
	#  netapp_transport_type => $netapp_cfg['netapp_transport_type'],
	#  netapp_vfiler => $netapp_cfg['netapp_vfiler'],
	#  expiry_thres_minutes => $netapp_cfg['expiry_thres_minutes'],
	#  thres_avl_size_perc_start => $netapp_cfg['thres_avl_size_perc_start'],
	#  thres_avl_size_perc_stop => $netapp_cfg['thres_avl_size_perc_stop'],
	#  nfs_shares_config => $netapp_cfg['nfs_shares_config'],
	#  netapp_copyoffload_tool_path => $netapp_cfg['netapp_copyoffload_tool_path'],
	#  netapp_controller_ips => $netapp_cfg['netapp_controller_ips'],
	#  netapp_sa_password => $netapp_cfg['netapp_sa_password'],
	#  netapp_storage_pools => $netapp_cfg['netapp_storage_pools'],
	#  netapp_webservice_path => $netapp_cfg['netapp_webservice_path'],
	#-  volume_driver,
	}
}

define osnailyfacter::cinder_netapp::netapp (
  $netapp_login,
  $netapp_password,
  $netapp_server_hostname,
  $volume_backend_name          = $name,
  $netapp_server_port           = '80',
  $netapp_size_multiplier       = '1.2',
  $netapp_storage_family        = 'ontap_cluster',
  $netapp_storage_protocol      = 'nfs',
  $netapp_transport_type        = 'http',
  $netapp_vfiler                = '',
  $netapp_volume_list           = '',
  $netapp_vserver               = '',
  $expiry_thres_minutes         = '720',
  $thres_avl_size_perc_start    = '20',
  $thres_avl_size_perc_stop     = '60',
  $nfs_shares_config            = '',
  $netapp_copyoffload_tool_path = '',
  $netapp_controller_ips        = '',
  $netapp_sa_password           = '',
  $netapp_storage_pools         = '',
  $netapp_webservice_path       = '/devmgr/v2',
) {

  cinder_config {
    #"${volume_backend_name}/volume_backend_name":          value => $volume_backend_name;
    "${volume_backend_name}/volume_driver":                value => 'cinder.volume.drivers.netapp.common.NetAppDriver';
    "${volume_backend_name}/netapp_login":                 value => $netapp_login;
    "${volume_backend_name}/netapp_password":              value => $netapp_password, secret => true;
    "${volume_backend_name}/netapp_server_hostname":       value => $netapp_server_hostname;
    "${volume_backend_name}/netapp_server_port":           value => $netapp_server_port;
    "${volume_backend_name}/netapp_storage_family":        value => $netapp_storage_family;
    "${volume_backend_name}/netapp_storage_protocol":      value => $netapp_storage_protocol;
    "${volume_backend_name}/netapp_volume_list":           value => $netapp_volume_list;
    "${volume_backend_name}/netapp_vserver":               value => $netapp_vserver;
  }

  #cinder_config {
    #"${volume_backend_name}/netapp_size_multiplier":       value => $netapp_size_multiplier;
    #"${volume_backend_name}/netapp_transport_type":        value => $netapp_transport_type;
    #"${volume_backend_name}/netapp_vfiler":                value => $netapp_vfiler;
    #"${volume_backend_name}/expiry_thres_minutes":         value => $expiry_thres_minutes;
    #"${volume_backend_name}/thres_avl_size_perc_start":    value => $thres_avl_size_perc_start;
    #"${volume_backend_name}/thres_avl_size_perc_stop":     value => $thres_avl_size_perc_stop;
    #"${volume_backend_name}/nfs_shares_config":            value => $nfs_shares_config;
    #"${volume_backend_name}/netapp_copyoffload_tool_path": value => $netapp_copyoffload_tool_path;
    #"${volume_backend_name}/netapp_controller_ips":        value => $netapp_controller_ips;
    #"${volume_backend_name}/netapp_sa_password":           value => $netapp_sa_password;
    #"${volume_backend_name}/netapp_storage_pools":         value => $netapp_storage_pools;
    #"${volume_backend_name}/netapp_webservice_path":       value => $netapp_webservice_path;
  #}
}

