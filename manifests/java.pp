#  zookeeper::install class
#  Installs java, inherits parameters from the main class

class zookeeper::java (
  $install        = $zookeeper::install_java,
  $package_name   = $zookeeper::java_package
) inherits zookeeper {


# Checks if the $install_java parameter is a boolean.
# interrupts catalog compilation if it's not.
  validate_bool($install)

  if $install == true {
  # Check whether the $java_package is a valid string.
    validate_string($package_name)

    ensure_resource('package', $package_name, { ensure => present })
  }
}
