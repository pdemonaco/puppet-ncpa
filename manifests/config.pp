# @summary Implementation detail - sets parameters in ncpa.cfg
class ncpa::config (
  Boolean $manage_firewall              = $ncpa::manage_firewall,
  Stdlib::Port $port                    = $ncpa::port,
  String $community_string              = $ncpa::community_string,
  String $install_dir                   = $ncpa::install_dir,
  String $plugin_dir                    = $ncpa::plugin_dir,
  Array[Ncpa::PluginFile] $plugin_files = $ncpa::plugin_files,
){
  # Configure the NCPA client
  $epp_parameters = {
    'community_string' => $community_string,
    'port'             => $port,
    'plugin_dir'       => $plugin_dir,
  }

  file { "${install_dir}/etc/ncpa.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => 'root',
    group   => 'nagios',
    content => epp('ncpa/ncpa.cfg.epp', $epp_parameters),
  }

  # Configure the firewall if specified
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

  # Configure the plugin directory
  $plugin_path = "${install_dir}/${plugin_dir}"
  file { $plugin_path:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Deploy each file specified in the plugin files array.
  unless(empty($plugin_files)) {
    $plugin_files.each |$entry| {
      $plugin_name = $entry['name']
      file { "${plugin_path}/${plugin_name}":
        ensure  => 'file',
        owner   => 'root',
        group   => 'nagios',
        mode    => '0644',
        source  => $entry['content'],
        require => File[$plugin_path],
      }
    }
  }
}
