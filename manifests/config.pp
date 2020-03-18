# @summary Implementation detail - sets parameters in ncpa.cfg
class ncpa::config (
  Boolean $manage_firewall = $ncpa::manage_firewall,
  Stdlib::Port $port       = $ncpa::port,
  String $community_string = $ncpa::community_string,
  String $install_dir      = $ncpa::install_dir,
  String $plugin_dir       = $ncpa::plugin_dir,
){

  $epp_parameters = {
    'community_string' => $community_string,
    'port'             => $port,
  }

  file { '/usr/local/ncpa/etc/ncpa.cfg':
    ensure  => file,
    mode    => '0644',
    owner   => 'nagios',
    group   => 'nagios',
    content => epp('ncpa/ncpa.cfg.epp', $epp_parameters),
  }

  if $manage_firewall {
    include firewalld

    firewalld::custom_service { 'ncpa_listener':
      description => 'Nagios Cross Platform Agent Listener Traffic',
      port        => [
        {
          'port'     => $port,
          'protocol' => 'tcp',
        },
      ],
    }
    firewalld_service { 'Nagios Cross Platform Agent Listener Traffic':
      ensure  => 'present',
      service => 'ncpa_listener',
      zone    => 'public',
    }
  }
}
