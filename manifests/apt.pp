# @summary Provides duo_unix for an apt-based environment (e.g. Debian/Ubuntu)
#
# @api private
#
class duo_unix::apt {
  $repo_file = '/etc/apt/sources.list.d/duosecurity.list'
  $repo_uri  = 'https://pkg.duosecurity.com'
  $package_state = $::duo_unix::package_version

  if $::duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed;
    }
  }

  if $::duo_unix::manage_repo {
    apt::source { 'duosecurity':
      location => $repo_uri,
      repos    => 'main',
      key      => {
        'id'     => '08C2A645DDF240B85844068D7A450864C1A07A85',
        'source' => 'https://duo.com/DUO-GPG-PUBLIC-KEY.asc'
      }
    }

    package { $::duo_unix::duo_package:
      ensure  => $package_state,
      require => Apt::Source['duosecurity'],
    }
  }
}
