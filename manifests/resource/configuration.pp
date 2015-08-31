# zookeeper configuration resource
# configures an instance of zookeeper,
# opens up firewall ports (if chosen so),
# and also installs the service
# (ONLY if the user chooses so).
define zookeeper::resource::configuration (
  $ensure                 = 'present',
  $user                   = $::zookeeper::user,
  $id                     = $::zookeeper::id,
  $jvmFlags               = $::zookeeper::jvmFlags,
  $purgeInterval          = $::zookeeper::purgeInterval,
  $dataLogDir             = $::zookeeper::dataLogDir,
  $dataDir                = $::zookeeper::dataDir,
  $configDir              = $::zookeeper::configDir,
  $clientPortAddress      = $::zookeeper::clientPortAddress,
  $globalOutstandingLimit = $::zookeeper::globalOutstandingLimit,
  $maxClientCnxns         = $::zookeeper::maxClientCnxns,
  $snapCount              = $::zookeeper::snapCount,
  $snapRetainCount        = $::zookeeper::snapRetainCount,
  $tickTime               = $::zookeeper::tickTime,
  $leaderServes           = $::zookeeper::leaderServes,
  $servers                = $::zookeeper::servers,
  $syncEnabled            = $::zookeeper::syncEnabled,
  $electionAlg            = $::zookeeper::electionAlg,
  $initLimit              = $::zookeeper::initLimit,
  $cnxTimeout             = $::zookeeper::cnxTimeout,
  $standaloneEnabled      = $::zookeeper::standaloneEnabled,
  $syncLimit              = $::zookeeper::syncLimit,
  $clientPort             = $::zookeeper::clientPort,
  $leaderPort             = $::zookeeper::leaderPort,
  $leaderElectionPort     = $::zookeeper::leaderElectionPort,
  $manage_service         = $::zookeeper::manage_service,
  $create_aio_service     = $::zookeeper::create_aio_service,
  $manage_firewall        = $::zookeeper::manage_firewall,
  $service_name           = $::zookeeper::service_name,
  $tmpDir                 = $::zookeeper::tmpDir,
  $installDir             = $::zookeeper::installDir,
  $localName              = $::zookeeper::localName
) {

  require zookeeper::install

  validate_re($ensure, '^(present|absent)$',"${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  if ($::zookeeper::manage_install == true) {
    file{ $configDir:
      ensure  => directory,
      path    => $configDir,
      source  => "${installDir}/conf",
      owner   => $user,
      purge   => true,
      force   => true,
      recurse => true,
      mode    => 'ug=rwxs,o=r'
    }
  }

  if !defined(File[$dataLogDir]) {
    file { $dataLogDir:
      ensure  => directory,
      owner   => $user,
      purge   => false,
      force   => true,
      recurse => true,
      mode    => 'ug=rwxs,o=r'
    }
  }

  file{ [$dataDir]:
    ensure  => directory,
    owner   => $user,
    purge   => false,
    force   => true,
    recurse => true,
    mode    => 'ug=rwxs,o=r'
  }

  file{ "${configDir}/zoo.cfg":
    ensure  => file,
    path    => "${configDir}/zoo.cfg",
    owner   => $user,
    mode    => 'ug=rwxs,o=r',
    purge   => true,
    force   => true,
    recurse => true,
    require => [File[$configDir]],
    content => template('zookeeper/conf/zoo.cfg.erb'),
  }

  file{ "${dataDir}/myid":
    ensure  => file,
    path    => "${dataDir}/myid",
    owner   => $user,
    mode    => 'ug+rwxs,o=rw',
    purge   => true,
    force   => true,
    recurse => true,
    require => [File[$dataLogDir],File[$configDir],File[$dataDir]],
    content => template('zookeeper/data/myid.erb')
  }

  if $manage_firewall == true {
    if !defined(Class['firewalld2iptables']) {
      class { 'firewalld2iptables':
        manage_package   => true,
        iptables_ensure  => 'latest',
        iptables_enable  => true,
        ip6tables_enable => true
      }
    }

    if !defined(Class['firewall']) {
      class { 'firewall': }
    }

    if !defined(Service['firewalld']) {
      service { 'firewalld':
        ensure => 'stopped'
      }
    }

    firewall { "${id}_zookeeper__allow_incoming":
      port        => [$clientPort, $leaderPort, $leaderElectionPort],
      proto       => 'tcp',
      require     => [Class['firewall']],
      destination => $clientPortAddress,
      action      => 'accept'
    }
  }

  if $manage_service == true {
    service { $service_name:
      ensure   => 'running',
      provider => 'systemd',
      enable   => true,
      require  => [Exec["Reload_for_${service_name}"]],
    }
    exec{ "Reload_for_${service_name}":
      path    => [$::path],
      command => 'systemctl daemon-reload',
      notify  => [Service[$service_name]],
      require => [File["${dataDir}/myid"],File["/usr/lib/systemd/system/${service_name}.service"]]
    }
    file { "/usr/lib/systemd/system/${service_name}.service":
      ensure  => 'file',
      purge   => true,
      force   => true,
      notify  => [Exec["Reload_for_${service_name}"]],
      require => [
        File[$configDir],
        File[$dataLogDir],
        File[$dataDir],
        File["${configDir}/zoo.cfg"],
        File["${dataDir}/myid"]
      ],
      content => template('zookeeper/service/zookeeper.service.erb'),
      owner   => $user,
      mode    => 'ug=rwxs,o=r'
    }
  }
}