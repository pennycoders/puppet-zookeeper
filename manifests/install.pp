#  zookeeper::install class
#  Installs zookeeper, inherits parameters from the main class

class zookeeper::install (
  $url                = $zookeeper::url,
  $follow_redirrects  = $zookeeper::follow_redirects,
  $extension          = $zookeeper::extension,
  $checksum           = $zookeeper::checksum,
  $digest_string      = $zookeeper::digest_string,
  $digest_type        = $zookeeper::digest_type,
  $user               = $zookeeper::user,
  $manage_user        = $zookeeper::manage_user,
  $tmpDir             = $zookeeper::tmpDir,
  $installDir         = $zookeeper::installDir
) inherits zookeeper {


# Check if $manage_user is a valid boolean value

  validate_bool($manage_user, $checksum, $follow_redirects)


# Check if all the string parameters are
# actually strings, halt if any of them is not.
  validate_string(
    $url,
    $digest_string,
    $digest_type,
    $extension,
    $user,
    $installDir,
    $tmpDir
  )

# Check if all the parameters supposed to be absolute paths are,
# fail if any of them is not.
  validate_absolute_path(
    [
      $installDir,
      $tmpDir
    ]
  )

  if $manage_user == true and !defined(User[$user]) and $user != 'root' {
    user { $user:
      ensure     => present,
      managehome => true,
      shell      => '/sbin/nologin',
      notify     => [File[$installDir]]
    }
  }elsif  $manage_user == true and !defined(User[$user]) and $user == 'root' {
    user { $user:
      ensure     => present,
      notify     => [File[$installDir]]
    }
  }

  archive { $url:
    ensure           => present,
    url              => $url,
    src_target       => $tmpDir,
    target           => $installDir,
    strip_components => 1,
    follow_redirects => $follow_redirects,
    extension        => $extension,
    checksum         => $checksum,
    notify           => [File[$installDir]],
    digest_string    => $digest_string,
    digest_type      => $digest_type
  }

  file{ $installDir:
    ensure  => directory,
    owner   => $user,
    recurse => true,
    require => [Archive[$url],User[$user]],
    mode    => 'ug=rwxs,o=r'
  }
}
