# duo_unix Puppet Module

## Table of Contents

### [Module Description](#module-description)
### [Setup](#setup)
### [Usage](#usage)
### [Limitations](#limitations)
### [Thanks](#thanks)

## Module Description

The duo_unix module handles the deployment of duo_unix (`login_duo` or 
`pam_duo`) across a range of Linux distributions. The module will handle 
repository dependencies, installation of the duo_unix package, configuration 
of OpenSSH, and PAM alterations as needed.

For further information about duo_unix, view the official
[documentation](https://www.duosecurity.com/docs/duounix).

## Setup

Clone this repo to `duo_unix`:

```sh
$ git clone https://github.com/mozilla-it/puppet-duo_unix duo_unix
```
This module requires [stdlib](https://forge.puppet.com/puppetlabs/stdlib).
Refer to metadata.json for the right version.

## Usage

```ruby
# duo_unix.pp
class { 'duo_unix':
  usage     => 'login',
  ikey      => 'YOUR-IKEY-VALUE',
  skey      => 'YOUR-SKEY-VALUE',
  host      => 'YOUR-HOST-VALUE',
  pushinfo  => 'yes'
}
```

```sh
puppet apply duo_unix.pp
```

## Limitations

This module built on and tested against Puppet 6.18 and tested on:

* CentOS 7.x (64-bit)
* CentOS 8.x (64-bit)

If you test the module on other Linux distributions (or different versions of 
the above), please provide feedback as able on successes or failures. 

**Caution:** The use of this module will edit OpenSSH and/or PAM configuration 
files depending on the usage defined. These modifications have only been tested
against default distribution configurations and could impact your settings. Be 
sure to test this module against non-production systems before attempting to 
deploy it across your critical infrastructure.

## Thanks
* Gregg Leventhal
* level99
* Denise Stockman
* Dan Cox
* Mark Stanislav
