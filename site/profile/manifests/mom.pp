class profile::mom {

  $enable_firewall      = hiera('profile::mom::enable_firewall',true)

  Firewall {
    proto  => tcp,
    action => accept,
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  class { 'app_update':
    application => true,
    agent       => false,
  }

  if $enable_firewall {
    firewall { '100 allow jmx access':
      dport   => [9010],
    }

    firewall { '100 allow puppet access':
      dport   => [8140],
    }

    firewall { '100 allow code manager access':
      dport   => [8170],
    }

    firewall { '100 allow pcp access':
      dport   => [8142],
    }

    firewall { '100 allow pcp client access':
      dport   => [8143],
    }

    firewall { '100 allow mco access':
      dport   => [61613],
    }

    firewall { '100 allow amq access':
      dport   => [61616],
    }

    firewall { '100 allow console access':
      dport   => [443],
    }

    firewall { '100 allow nc access':
      dport   => [4433],
    }

    firewall { '100 allow puppetdb access':
      dport   => [8081],
    }

    firewall { '100 allow postgresql access':
      dport   => [5432],
    }
  }

  @@nagios_service { "${::fqdn}_puppet":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $::fqdn,
    service_description => "Puppet Master",
    check_command       => 'check_http! -p 8140 -S -u /production/node/test',
    target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
  }

  package { 'puppetclassify':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
}
