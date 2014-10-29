class murano::keystone (
  $user     = 'murano',
  $password = 'swordfish',
  $tenant   = 'services',
  $email    = 'murano@localhost'
) {

  if ! $::fuel_settings['keystone']['use_ldap'] {
    keystone_user { $user:
      ensure      => present,
      enabled     => true,
      tenant      => $tenant,
      email       => $email,
      password    => $password,
    }
  
    keystone_user_role { "${user}@${tenant}":
      roles  => 'admin',
      ensure => present,
    }
  }

}
