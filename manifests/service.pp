# @summary Implementation detail - enables both ncpa services
class ncpa::service {
  service { ['ncpa_listener', 'ncpa_passive']:
    ensure => running,
    enable => true,
  }
}
