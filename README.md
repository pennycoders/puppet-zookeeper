## Overview:
    This is a puppet module which can both install and manage Apache Zookeeper.
    It incorporates support for running multiple zookeeper instances on the same machine,
    which comes in handy, mostly when your infrastructure is in it's early days, when there are
    not many machines. 
 
## "What's in the box":
    There are three things that this module provides:
     - The zookeeper class, which is the main class that should install the desired zookeeper version.
     - The zookeeper::install class, which inherits the main class, and is not really meant to be used
       by itself (Inherits parameters from the main class).
     - The zookeeper::configuration resource, which is supposed to be used for configuring a zookeeper instance
       on a given machine.
       
## Usage guide:
In order to be able to use  this module, you first need to add it to your dependencies list.
### Usage example:
#### Simple usage:
##### The zookeeper class:
```puppet
    include zookeeper
```
or
```puppet
    class {'zookeeper': }
```
##### The configuration resource:
  Please note that the servers parameter should look like below:
```puppet
  ...
    servers => {
      1 =>{
          ip => '127.0.0.1',
          leaderPort => 2888,
          electionPort => 3888
        }
      }
  ...
```
```puppet
    zookeeper::resource::configuration{'localhost':}
```
#### Advanced usage:
    Please note that the usage example you see below contains all the possible parameters, 
    as well as the default value for each parameter.
##### zookeeper class:
```puppet
  class {'zookeeper':
    id                     => 1,
    url                    => 'http://www.eu.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz',
    digest_string          => '971c379ba65714fd25dc5fe8f14e9ad1',
    follow_redirects       => true,
    extension              => 'tar.gz',
    checksum               => true,
    digest_type            => 'md5',
    user                   => 'zookeeper',
    manage_user            => true,
    tmpDir                 => '/tmp',
    installDir             => '/opt',
    jvmFlags               => '-Dzookeeper.log.threshold=INFO -Xmx1024m',
    dataLogDir             => '/var/log/zookeeper',
    dataDir                => '/var/lib/zookeeper',
    configDir              => '/etc/zookeeper',
    clientPortAddress      => "127.0.0.1",
    globalOutstandingLimit => 1000,
    maxClientCnxns         => 2000,
    snapCount              => 100000,
    cnxTimeout             => 20000,
    purgeInterval          => 1,
    snapRetainCount        => 3,
    tickTime               => 60000,
    leaderServes           => 'yes',
    servers                => { },
    syncEnabled            => true,
    standaloneEnabled      => true,
    electionAlg            => 3,
    initLimit              => 5,
    syncLimit              => 5,
    clientPort             => 2181,
    leaderPort             => 3888,
    leaderElectionPort     => 2888,
    install_java           => true,
    java_package           => 'java-1.8.0-openjdk',
    manage_service         => true,
    create_aio_service     => true,
    manage_firewall        => true,
    service_name           => 'zookeeper'
  }
```
##### configuration resource:
```puppet
  zookeeper::resource::configuration {'localhost':
    ensure                 => 'present',
    user                   => $::zookeeper::user,
    id                     => $::zookeeper::id,
    jvmFlags               => $::zookeeper::jvmFlags,
    purgeInterval          => $::zookeeper::purgeInterval,
    dataLogDir             => $::zookeeper::dataLogDir,
    dataDir                => $::zookeeper::dataDir,
    configDir              => $::zookeeper::configDir,
    clientPortAddress      => $::zookeeper::clientPortAddress,
    globalOutstandingLimit => $::zookeeper::globalOutstandingLimit,
    maxClientCnxns         => $::zookeeper::maxClientCnxns,
    snapCount              => $::zookeeper::snapCount,
    snapRetainCount        => $::zookeeper::snapRetainCount,
    tickTime               => $::zookeeper::tickTime,
    leaderServes           => $::zookeeper::leaderServes,
    servers                => $::zookeeper::servers,
    syncEnabled            => $::zookeeper::syncEnabled,
    electionAlg            => $::zookeeper::electionAlg,
    initLimit              => $::zookeeper::initLimit,
    cnxTimeout             => $::zookeeper::cnxTimeout,
    standaloneEnabled      => $::zookeeper::standaloneEnabled,
    syncLimit              => $::zookeeper::syncLimit,
    clientPort             => $::zookeeper::clientPort,
    leaderPort             => $::zookeeper::leaderPort,
    leaderElectionPort     => $::zookeeper::leaderElectionPort,
    manage_service         => $::zookeeper::manage_service,
    create_aio_service     => $::zookeeper::create_aio_service,
    manage_firewall        => $::zookeeper::manage_firewall,
    service_name           => $::zookeeper::service_name,
    tmpDir                 => $::zookeeper::tmpDir,
    installDir             => $::zookeeper::installDir
  }
```

## Other notes:
    This module was built to manage a clustered zookeeper setup. 
    In case you encounter any issues with it, do not hesitate to signal them on GitHub.
  
## OS Support:
    This has only been tested on CentOS 7, for which it was created in the first place.
    