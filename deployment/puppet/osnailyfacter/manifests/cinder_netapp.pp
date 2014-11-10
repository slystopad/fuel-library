$fuel_settings = parseyaml($astute_settings_yaml)
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

class {'osnailyfacter::cinder_netapp':
  netapp_cfg => $netapp_hash,
}
