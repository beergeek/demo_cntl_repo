# Using automagic data lookups
class profile::base (
  $noop_scope = false,
) {

  if $::brownfields and $noop_scope {
    noop(true)
  } else {
    noop(false)
  }

  case $::kernel {
    'linux': {
      $sysctl_settings  = hiera('profile::base::sysctl_settings')
      $sysctl_defaults  = hiera('profile::base::sysctl_defaults')
      $enable_firewall  = hiera('profile::base::enable_firewall',true)

      Firewall {
        before  => Class['profile::fw::post'],
        require => Class['profile::fw::pre'],
      }

      if $enable_firewall {
        class { 'firewall':
          ensure => running,
        }
        include profile::fw::pre
        include profile::fw::post
      } else {
        class { 'firewall':
          ensure => stopped,
        }
      }

      contain epel
      include make_noop

      # old way
      # create_resources(sysctl,$sysctl_settings, $sysctl_defaults)
      # new way
      $sysctl_settings.each |String $sysctl_name, Hash $sysctl_hash| {
        sysctl { $sysctl_name:
          * => $sysctl_hash,;
          default:
            * => $sysctl_defaults,;
        }
      }

      ensure_packages(['ruby'])
      file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0750',
      }

      # repo management
      include profile::repos

      # monitoring
      include profile::monitoring

      # manage time, timezones, and locale
      include profile::time_locale

      # manage SSH
      include profile::ssh

      # manage SUDO
      include profile::sudo

      # manage logging
      #include profile::logging

      # manage DNS stuff
      include profile::dns

      exec { 'update mco facts':
        command => '/opt/puppetlabs/puppet/bin/refresh-mcollective-metadata >>/var/log/puppetlabs/mcollective-metadata-cron.log 2>&1',
        unless  => '/usr/bin/test -e /etc/puppetlabs/mcollective/facts.yaml',
      }
    }
    'windows': {

      $wsus_server      = hiera('profile::base::wsus_server')
      $wsus_server_port = hiera('profile::base::wsus_server_port')

      include chocolatey
      Class['chocolatey'] -> Package<||>

      reboot { 'after_dotnet':
        apply => 'immediately',
        when  => pending,
      }

      reboot { 'after_powershell':
        apply => 'immediately',
        when  => pending,
      }

      package { 'dotnet4.5.2':
        ensure          => present,
        provider        => 'chocolatey',
        notify          => Reboot['after_dotnet'],
      }

      package { 'powershell':
        ensure          => present,
        provider        => 'chocolatey',
        install_options => ['-pre'],
        notify          => Reboot['after_powershell'],
      }

      # monitoring
      include profile::monitoring

      file { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        ensure => directory,
      }

      acl { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        purge                      => false,
        permissions                => [
          { identity => 'vagrant', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all' },
          { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
        ],
        owner                      => 'vagrant',
        group                      => 'Administrators',
        inherit_parent_permissions => true,
      }

      # setup wsus client
      class { 'wsus_client':
        server_url => "${wsus_server}:${wsus_server_port}",
      }
    }
  }

}
