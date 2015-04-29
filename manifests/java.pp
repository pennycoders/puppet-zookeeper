#  zookeeper::install class
#  Installs java, inherits parameters from the main class

class zookeeper::java (
  $install        = $zookeeper::install_java,
  $package_name   = $zookeeper::java_package
) inherits zookeeper {

# Checks if the $install_java parameter is a boolean.
# interrupts catalog compilation if it's not.
  validate_bool($install_java)

  if $install_java == true {
  # Check whether the $java_package is a valid string.
    validate_string($java_package)

    ensure_resource('package', $package_name, { ensure => present })
  }
}
