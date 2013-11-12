# == Class: viewvc
#
# Module to manage ViewVC
#
class viewvc (
  $package        = 'viewvc',
  $config_path    = '/etc/viewvc/viewvc.conf',
  $config_mode    = '0644',
  $config_owner   = 'root',
  $config_group   = 'root',
  $vhost_port     = '80',
  $vhost_docroot  = '/var/www/viewvc',
  $vhost_template = 'viewvc/vhost.conf.erb',
  $apache_user    = 'USE_DEFUALT',
  $apache_group   = 'USE_DEFUALT',
  $root_parents   = undef,
) {

  case $::osfamily {
    'RedHat' : {
      case $::lsbmajdistrelease {
        '6': {
          $default_apache_user = 'apache'
          $default_apache_group = 'apache'
        }
        default: {
          fail("viewvc is supported on EL 6. Your osfamily and lsbmajdistrelease identified as ${::osfamily} ${::lsbmajdistrelease}.")
        }
      }
    }
    default: {
      fail("viewvc is supported on osfamily RedHat. Your osfamily identified as ${::osfamily}.")
    }
  }

  include apache

  if $apache_user == 'USE_DEFAULT' {
    $my_apache_user = $default_apache_user
  } else {
    $my_apache_user = $apache_user
  }

  if $apache_group == 'USE_DEFAULT' {
    $my_apache_group = $default_apache_group
  } else {
    $my_apache_group = $apache_group
  }

  $apache::params::user = $my_apache_user
  $apache::params::group = $my_apache_group

  package { 'viewvc_package':
    ensure => installed,
    name   => $package,
  }

  file { 'viewvc_conf':
    ensure  => file,
    path    => $config_path,
    mode    => $config_mode,
    owner   => $config_owner,
    group   => $config_group,
    content => template('viewvc/viewvc.conf.erb'),
    require => Package['viewvc_package'],
  }

  apache::vhost { 'viewvc':
    priority           => '10',
    port               => $http_port,
    docroot            => $vhost_docroot,
    template           => $vhost_template,
    configure_firewall => false,
  }
}
