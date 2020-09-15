# == Class: duo_unix::generic
#
# Provides usage-agnostic duo_unix functionality
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
class duo_unix::generic {
  file { '/usr/sbin/login_duo':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '4755',
    require => Package[$::duo_unix::duo_package];
  }

  if $facts['os']['family'] != 'RedHat' or $::duo_unix::manage_repo {
    file { $::duo_unix::gpg_file:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      # Updated 2020-03, see https://help.duo.com/s/article/5503
      source => 'puppet:///modules/duo_unix/DUO-GPG-PUBLIC-KEY',
      notify => Exec['Duo Security GPG Import'];
    }
  }

  if $::duo_unix::manage_ssh {
    service { $::duo_unix::ssh_service:
      ensure => running,
      enable => true;
    }
  }

}
