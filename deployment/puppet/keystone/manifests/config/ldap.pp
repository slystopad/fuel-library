#
# This class implements a config fragment for
# the ldap specific backend for keystone.
#
# == Dependencies
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::ldap(
  $url            = 'ldap://localhost',
  $user           = 'dc=Manager,dc=example,dc=com',
  $password       = 'None',
  $suffix         = 'cn=example,cn=com',
  $user_tree_dn   = 'ou=Users,dc=example,dc=com',
  $tenant_tree_dn = 'ou=Roles,dc=example,dc=com',
  $role_tree_dn   = 'dc=example,dc=com'
) {

  keystone_config {
    'ldap/url':            value => $url;
    'ldap/user':           value => $user;
    'ldap/password':       value => $password;
    'ldap/suffix':         value => $suffix;
    'ldap/user_tree_dn':   value => $user_tree_dn;
    'ldap/tenant_tree_dn': value => $tenant_tree_dn;
    'ldap/role_tree_dn':   value => $role_tree_dn;
    #"ldap/tree_dn" value => "dc=example,dc=com",
  }
}

class keystone::config::ldap(
  $url            = $::fuel_settings['keystone_ldap']['ldap_url'],
  $user           = $::fuel_settings['keystone_ldap']['ldap_user'],
  $password       = $::fuel_settings['keystone_ldap']['ldap_pass'],
  $suffix         = $::fuel_settings['keystone_ldap']['ldap_suffix'],
  $user_tree_dn   = $::fuel_settings['keystone_ldap']['ldap_user_tree_dn'],
  $tenant_tree_dn = $::fuel_settings['keystone_ldap']['ldap_tenant_tree_dn'],
  $role_tree_dn   = $::fuel_settings['keystone_ldap']['ldap_role_tree_dn'],
  $group_tree_dn   = $::fuel_settings['keystone_ldap']['ldap_group_tree_dn'],
  $user_filter    = $::fuel_settings['keystone_ldap']['ldap_user_filter'],
  $role_filter    = $::fuel_settings['keystone_ldap']['ldap_role_filter'],
  $tenant_filter  = $::fuel_settings['keystone_ldap']['ldap_tenant_filter'],
  $tenant_id_prefix = $::fuel_settings['keystone_ldap']['ldap_tenant_id_prefix'],
  $tenant_name_prefix = $::fuel_settings['keystone_ldap']['ldap_tenant_name_prefix'],
  $role_id_prefix = $::fuel_settings['keystone_ldap']['ldap_role_id_prefix'],
  $role_name_prefix = $::fuel_settings['keystone_ldap']['ldap_role_name_prefix'],
  $ldap_driver    = 'keystone.identity.backends.ldap.Identity',
) {

  if ! defined(Package['python-ldap']) {
    package { 'python-ldap': ensure => installed, }

    Package['python-ldap'] -> Keystone_config<||>
  }

  keystone_config {
    'ldap/url':            value => $url;
    'ldap/user':           value => "'${user}'";
    'ldap/password':       value => $password;
    'ldap/suffix':         value => $suffix;
    'ldap/user_tree_dn':   value => "'${user_tree_dn}'";
    'ldap/tenant_tree_dn': value => "'${tenant_tree_dn}'";
    'ldap/role_tree_dn':   value => "'${role_tree_dn}'";
    'ldap/user_filter':    value => $user_filter;
    'ldap/role_filter':    value => $role_filter;
    'ldap/tenant_filter':  value => $tenant_filter;
    'ldap/group_tree_dn':  value => "'${group_tree_dn}'";
    'ldap/query_scope':    value => "sub";
    'identity/driver':     value => $ldap_driver;
    #"ldap/tree_dn" value => "dc=example,dc=com",
    'ldap/role_id_prefix':   value => $role_id_prefix;
    'ldap/tenant_id_prefix': value => $tenant_id_prefix;
    'ldap/role_name_prefix':   value => $role_name_prefix;
    'ldap/tenant_name_prefix': value => $tenant_name_prefix;
    #
    'ldap/user_allow_create':       value => "False";
    'ldap/user_allow_update':       value => "False";
    'ldap/user_allow_delete':       value => "False";
  }
}
