Puppet::Type.type(:ini_setting)#.providers

Puppet::Type.type(:neutron_f5_bigip_lbaas_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    ## ini file without sections sections
    #resource[:name].split('/', 2).first
    return ""
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def file_path
    '/etc/neutron/f5-bigip-lbaas-agent.ini'
  end

end
