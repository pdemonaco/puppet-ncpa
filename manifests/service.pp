# @summary Implementation detail - enables both ncpa services
class ncpa::service (
  Array[String] $services = $ncpa::services,
){
  if $facts['kernel'] == 'windows' {
    $mode = 'delayed'
  } else {
    $mode = 'true'
  }

  service { $services:
    ensure => 'running',
    enable => $mode,
  }
}
