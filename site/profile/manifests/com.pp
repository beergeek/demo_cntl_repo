class profile::com {

  $enable_firewall = hiera('profile::com::enable_firewall',true)

  if has_key($::networking['interfaces'],'enp0s8') {
    $ip = $::networking['interfaces']['enp0s8']['ip']
  } elsif has_key($::networking['interfaces'],'eth1') {
    $ip = $::networking['interfaces']['eth1']['ip']
  } elsif has_key($::networking['interfaces'],'enp0s3') {
    $ip = $::networking['interfaces']['enp0s3']['ip']
  } elsif has_key($::networking['interfaces'],'eth0') {
    $ip = $::networking['interfaces']['eth0']['ip']
  } else {
    fail("Buggered if I know your IP Address")
  }

  if $enable_firewall {
    Firewall {
      before  => Class['profile::fw::post'],
      require => Class['profile::fw::pre'],
    }

    firewall { '100 allow puppet access':
      dport  => [8140],
      proto  => tcp,
      action => accept,
    }

    firewall { '100 allow mco access':
      dport  => [61613],
      proto  => tcp,
      action => accept,
    }

    firewall { '100 allow amq access':
      dport  => [61616],
      proto  => tcp,
      action => accept,
    }
  }

  if $manage_hiera and (! $hiera_backends or ! $hiera_hierarchy) {
    fail('The hash `hiera_backends` and array `hiera_hierarchy` must exist when managing hiera')
  }

  if $::trusted['extensions']['pp_role'] != 'replica' {
    @@haproxy::balancermember { "master00-${::fqdn}":
      listening_service => 'puppet00',
      server_names      => $::fqdn,
      ipaddresses       => $ip,
      ports             => '8140',
      options           => 'check',
    }
    @@haproxy::balancermember { "mco00-${::fqdn}":
      listening_service => 'mco00',
      server_names      => $::fqdn,
      ipaddresses       => $ip,
      ports             => '61613',
      options           => 'check',
    }
  }

  @@puppet_certificate { "${::fqdn}-peadmin":
    ensure => present,
    tag    => 'mco_clients',
  }

  puppet_enterprise::mcollective::client { "${::fqdn}-peadmin":
    activemq_brokers => [$::clientcert],
    logfile          => "/var/lib/${::fqdn}-peadmin/${::fqdn}-peadmin.log",
    create_user      => true,
  }

}
