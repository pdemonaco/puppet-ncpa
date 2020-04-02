# @summary Implementation detail - enables both ncpa services
class ncpa::service (
  Array[String] $services = $ncpa::services,
){
  service { $services:
    ensure => running,
    enable => true,
  }
}
