# @summary Installs and configures Duo
#
# @api public
#
# @example Basic usage
#   class { 'duo_unix':
#     usage     => 'login',
#     ikey      => 'YOUR-IKEY-VALUE',
#     skey      => 'YOUR-SKEY-VALUE',
#     host      => 'YOUR-HOST-VALUE',
#     pushinfo  => 'yes'
#   }
#
# @see https://duo.com/docs/duounix
#
# @param ikey
#   Sets the integration key
# @param skey
#   Sets the secret key
# @param host
#   Sets the Duo API server
# @param usage
#   Choose whether to setup via PAM or LOGIN
# @param group
#   Only enable Duo for selected group
# @param http_proxy
#   Use specified HTTP proxy for outbound requests to the Duo API server
# @param send_gecos
#   Send the entire GECOS field as the Duo username
# @param fallback_local_ip
#   Send local server's IP address if Duo cannot detect the user's IP
# @param failmode
#   On service or config errors, allow ("safe") or deny ("secure") access
# @param pushinfo
#   Include information such as the command to be executed in the Duo Push message
# @param autopush
#   Automatically send a push login request to the user's phone or failback to other methods
# @param motd
#   Print the contents of /etc/motd to screen after a successful login (only if $usage = login)
# @param prompts
#   Number of prompts per authentication
# @param accept_env_factor
#   Look for passcode in $DUO_PASSCODE environment variable
# @param manage_ssh
#   Manage SSH packages and config
# @param manage_pam
#   Manage PAM config using Augeas
# @param manage_repo
#   Manage rpm and deb package repositories for Duo
# @param pam_unix_control
#   Use the specified control mechanism for PAM
# @param package_version
#   Override `ensure` for the Duo Linux package
#
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
        default => fail("Module duo_unix does not support architecture ${facts['architecture']}")
      }

      include ::duo_unix::apt
      include ::duo_unix::generic
    }
    default: {
      fail("Module duo_unix does not support ${facts['os']['family']}")
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
