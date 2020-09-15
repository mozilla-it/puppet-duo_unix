# == Class: duo_unix
#
# Core class for duo_unix module
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
class duo_unix (
  String[20] $ikey,
  String[40] $skey,
  Stdlib::Host $host,
  Enum['login', 'pam'] $usage = 'pam',
  Optional[String[1]] $group = undef,
  Optional[String[1]] $http_proxy = undef,
  Enum['yes', 'no'] $send_gecos = 'no',
  Enum['yes', 'no'] $fallback_local_ip = 'no',
  Enum['safe', 'secure'] $failmode = 'safe',
  Enum['yes', 'no'] $pushinfo = 'no',
  Enum['yes', 'no'] $autopush = 'no',
  Enum['yes', 'no'] $motd = 'no',
  Integer[1, 3] $prompts = 3,
  Enum['yes', 'no'] $accept_env_factor = 'no',
  Boolean $manage_ssh = true,
  Boolean $manage_pam = true,
  Boolean $manage_repo = true,
  Enum['sufficient', 'required', 'requisite'] $pam_unix_control = 'requisite',
  Enum['latest', 'present', 'installed'] $package_version = 'installed',
) {

  case $facts['os']['family'] {
    'RedHat': {
      $duo_package = 'duo_unix'
      $ssh_service = 'sshd'
      $gpg_file    = '/etc/pki/rpm-gpg/DUO-GPG-PUBLIC-KEY'

      $pam_file    = '/etc/pam.d/password-auth'
      $pam_module  = '/lib64/security/pam_duo.so'

      include ::duo_unix::yum
      include ::duo_unix::generic
    }
    'Debian': {
      $duo_package = 'duo-unix'
      $ssh_service = 'ssh'
      $gpg_file    = '/etc/apt/DUO-GPG-PUBLIC-KEY'
      $pam_file    = '/etc/pam.d/common-auth'

      $pam_module  = $facts['architecture'] ? {
        'i386'  => '/lib/security/pam_duo.so',
        'i686'  => '/lib/security/pam_duo.so',
        'amd64' => '/lib64/security/pam_duo.so',
        default => fail("Module ${module_name} does not support architecture ${facts['architecture']}")
      }

      include ::duo_unix::apt
      include ::duo_unix::generic
    }
    default: {
      fail("Module ${module_name} does not support ${facts['os']['family']}")
    }
  }

  case $usage {
    'login': {
      include ::duo_unix::login
    }
    'pam': {
      include ::duo_unix::pam
    }
    # We wouldn't hit the default case because $usage is an enum, but
    # we add this here to please the linter
    default: {}
  }
}
