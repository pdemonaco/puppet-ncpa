# @summary Implementation detail - sets parameters in ncpa.cfg
class ncpa::config (
  Boolean $manage_firewall              = $ncpa::manage_firewall,
  Stdlib::Port $port                    = $ncpa::port,
  String $community_string              = $ncpa::community_string,
  String $install_dir                   = $ncpa::install_dir,
  String $plugin_dir                    = $ncpa::plugin_dir,
  Array[Ncpa::PluginFile] $plugin_files = $ncpa::plugin_files,
){
  # File & Folder Permissions are different on windows
  case $facts['kernel'] {
    'windows': {
      $dir_base = {
        'ensure' => 'directory',
        'owner'  => 'Administrators'
      }
      $file_base = {
        'ensure' => 'file',
        'owner'  => 'Administrators'
      }
    }
    default: {
      $dir_base = {
        'ensure' => 'directory',
        'owner'  => 'root',
        'group'  => 'nagios',
        'mode'   => '0755',
      }
      $file_base = {
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'nagios',
        'mode'   => '0644',
      }
    }
  }

  # Configure the NCPA client
  $epp_parameters = {
    'community_string' => $community_string,
    'port'             => $port,
    'plugin_dir'       => $plugin_dir,
  }

  file { "${install_dir}/etc/ncpa.cfg":
    content => epp('ncpa/ncpa.cfg.epp', $epp_parameters),
    *       => $file_base,
  }

  # Configure the firewall if specified
  if $facts['kernel'] == 'Linux' {
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

  # Configure the plugin directory
  $plugin_path = "${install_dir}/${plugin_dir}"
  file { $plugin_path:
    * => $dir_base,
  }

  # Deploy each file specified in the plugin files array.
  unless(empty($plugin_files)) {
    $plugin_files.each |$entry| {
      $plugin_name = $entry['name']
      file { "${plugin_path}/${plugin_name}":
        source  => $entry['content'],
        require => File[$plugin_path],
        *       => $file_base,
      }
    }
  }

  # Configure standard ACL for the plugin directory on windows
  if $facts['kernel'] == 'windows' {
    acl { $plugin_path:
      inherit_parent_permissions => true,
    }
  }
}
