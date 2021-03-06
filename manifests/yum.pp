# @summary Provides duo_unix for a yum-based environment (e.g. RHEL/CentOS)
#
# @api private
#
class duo_unix::yum {
  $repo_uri = 'https://pkg.duosecurity.com'
  $package_state = $::duo_unix::package_version

  case $facts['operatingsystem'] {
    'OracleLinux': {
      $os         = 'CentOS'
      $releasever = '$releasever'
    }
    default: {
      $os         = $facts['operatingsystem']
      $releasever = '$releasever'
    }
  }

  if $facts['os']['family'] == 'RedHat' and $::duo_unix::manage_repo {
    yumrepo { 'duosecurity':
      descr    => 'Duo Security Repository',
      baseurl  => "${repo_uri}/${os}/${releasever}/\$basearch",
      gpgcheck => '1',
      enabled  => '1',
      gpgkey   => "file://${::duo_unix::gpg_file}",
      before   => Package[$::duo_unix::duo_package],
      require  => File[$::duo_unix::gpg_file];
    }
  }

  if $::duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed,
    }
  }

  package {  $::duo_unix::duo_package:
    ensure  => $package_state,
  }

}

