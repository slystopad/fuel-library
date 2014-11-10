class osnailyfacter::cinder_netapp2 (
  $netapp_cfg   = $::fuel_settings['netapp']
){
        #osnailyfacter::cinder::backend::netapp {'netapp':
        osnailyfacter::cinder_netapp::netapp {'DEFAULT':
           netapp_login => $netapp_cfg['netapp_login'],
           netapp_password => $netapp_cfg['netapp_password'],
           netapp_server_hostname => $netapp_cfg['netapp_server_hostname'],
           netapp_server_port => $netapp_cfg['netapp_server_port'],
           netapp_storage_family => $netapp_cfg['netapp_storage_family'],
           netapp_storage_protocol => $netapp_cfg['netapp_storage_protocol'],
           netapp_volume_list => $netapp_cfg['netapp_volume_list'],
           netapp_vserver => $netapp_cfg['netapp_vserver'],
           #volume_backend_name => $netapp_cfg['volume_backend_name'],
        }
}

