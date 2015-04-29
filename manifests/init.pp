#
# Class: zookeeper
#
# This module manages Apache Zookeeper.
# It has support for running multiple
# instances on the same machine.
#
# Parameters:
#
#   This is an unique ID for your desired instance id, and it needs to be an integer number between 1 and 255
#   $id  - myid - see http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_zkMulitServerSetup
#
#   The url to the zookeeper archive
#   $url
#
#   The local file name, WITHOUT extension
#   $localName
#
#   The archive's format/extension
#   $extension
#
#   Whether to verify the archive's integrity (requires $digest_type and $digest_string)
#   $checksum
#
#   The url to the md5/sha1 checksum file for the archive
#   $digest_string
#
#   The type of the checksum
#   $digest_type
#
#   Whether to follow http redirects in order to get to the file
#   $follow_redirects
#
#   This is the url to the desired .tar.gz file.
#   $url - see http://www.apache.org/dyn/closer.cgi/zookeeper/ and chose the mirror closest to you
#
#   The desired installation directory (Will not be created, it needs to exist)
#   $installDir
#
#   The path to the directory where you wish your configuration to be stored (Please note that this diirectory ill automatically be created if it does not exist)
#   $configDir - see http://zookeeper.apache.org/doc/r3.3.3/zookeeperAdmin.html#sc_zkMulitServerSetup
#
#   The path to the data where you wish zooKeeper to store data (Directory will be automatically created if it does not exist)
#   $dataDir
#
#   See http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_configuration
#   $tickTime
#
#   See http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_configuration
#   $syncEnabled
#
#   Leader election algorithm http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_configuration
#   $electionAlg
#
#   The data log directory - see http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_configuration
#   $dataLogDir
#
#
#
#
#   The directory where zooKeeper will be downloaded
#   $tmpDir
#
#   Whether to install java or not
#   $install_java
#
#   Java package's name (Defaults to java-1.8.0-jdk)
#   $java_package
#
#   The desired name for the service
#   $service_name
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#   class { 'zookeeper::install':
#           url=>'http://www.eu.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz'
#           localName=>'zookeeper-3.4.6',
#           extension=>'tar.gz',
#           user=>'infrastructure'
#         }
#

class zookeeper (
  $id                     = 1,
  $url                    = 'http://www.eu.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz',
  $digest_string          = '971c379ba65714fd25dc5fe8f14e9ad1',
  $follow_redirects       = true,
  $extension              = 'tar.gz',
  $checksum               = true,
  $digest_type            = 'md5',
  $user                   = 'root',
  $manage_user            = true,
  $tmpDir                 = '/tmp',
  $installDir             = '/opt/zookeeper',
  $jvmFlags               = '-Dzookeeper.log.threshold=INFO -Xmx1024m',
#  Zookeeper configuration parameters
  $dataLogDir             = '/var/log/zookeeper',
  $dataDir                = '/var/lib/zookeeper',
  $configDir              = '/etc/zookeeper',
  $clientPortAddress      = '127.0.0.1',
  $globalOutstandingLimit = 1000,
  $maxClientCnxns         = 2000,
  $snapCount              = 100000,
  $cnxTimeout             = 20000,
  $purgeInterval          = 1,
  $snapRetainCount        = 3,
  $tickTime               = 60000,
  $leaderServes           = 'yes',
  $servers                = { },
  $syncEnabled            = true,
  $standaloneEnabled      = true,
  $electionAlg            = 3,
  $initLimit              = 5,
  $syncLimit              = 5,
  $clientPort             = 2181,
  $leaderPort             = 3888,
  $leaderElectionPort     = 2888,
#  Zookeeper configuration parameters end
  $install_java           = true,
  $java_package           = 'java-1.8.0-openjdk',
  $manage_service         = true,
  $create_aio_service     = true,
  $manage_firewall        = true,
  $service_name           = 'zookeeper'
) {


# Check if $server is a hash.
  validate_hash($servers)

# Check if $install_java and $create_user are boolean values.
  validate_bool($install_java, $manage_user, $checksum, $follow_redirects, $syncEnabled, $manage_service,$create_aio_service, $manage_firewall)

# Check if all the string parameters are actually strings, halt if any of them is not.
  validate_string(
    $url,
    $user,
    $extension,
    $leaderServes,
    $digest_string,
    $digest_type,
    $installDir,
    $configDir,
    $dataDir,
    $jvmFlags,
    $dataLogDir,
    $tmpDir,
    $java_package,
    $service_name,
    $clientPortAddress
  )

# Check if all the parameters supposed to be absolute paths are,
# fail if any of them is not.
  validate_absolute_path(
    [
      $installDir,
      $configDir,
      $dataDir,
      $tmpDir
    ]
  )


# Check if all the parameters which are
# supposed to be integer numbers are, fail if any of them is not.

  validate_integer(
    [
      $clientPort,
      $initLimit,
      $syncLimit,
      $cnxTimeout,
      $leaderElectionPort,
      $leaderPort,
      $snapCount,
      $snapRetainCount,
      $tickTime,
      $purgeInterval,
      $globalOutstandingLimit,
      $maxClientCnxns
    ]
  )

# Check if $id is an array of integers
# between 1 and 255, validate if it's
# smaller or bigger, fail if any of
# these criterias is not met.
  validate_integer($id,255,1)

# Check if the $clientPortAddress parameter is a valid IP address.
  if is_ip_address($clientPortAddress) == false {
    fail("The speciffied address (${clientPortAddress}) is not valid.")
  }

# Check if the passed ip address
# actually exists on the host,
# fail if it does not.
  if !has_interface_with('ipaddress', $clientPortAddress) {
    fail("The speciffied address (${clientPortAddress}) is not associated with ${::hostname}.")
  }

  class { 'zookeeper::java': }->
  class { 'zookeeper::install': }

}
