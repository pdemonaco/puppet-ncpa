# @summary Manages Nagios Cross-Platform Agent on RedHat family systems
#
# @param community_string
#   The community string that the agent will use to authenticate inbound
#   connections.
#
# @param manage_repo
#   When true the nagios repo will be installed. Typically this repo resides at
#   https://repo.nagios.rcom/nagios/
#
# @param manage_firewall
#   When true firewalld will be configured to allow inbound TCP connections on
#   the listener port.
#
# @param port
#   TCP port the listener daemon uses to provide access for the check_ncpa.py
#   command on a nagios server. It also provides a web interface that can be
#   accessed using the community string.
#
# @param install_dir
#   Base directory containing the installation of the ncpa agent. This is
#   configured via defaults set in hiera and is typically `/usr/local/ncpa` or
#   `C:\Program Files (x86)\Nagios\NCPA` for Linux and Windows respectively.
#
# @param plugin_dir
#   Directory in which plugins will be installed on the target host.
#   This is also used as the plugin_dir directive. Note that the deployment
#   currently assumes this is a subdirectory of $install_dir
#
# @param plugin_files
#   Array of Ncpa::PluginFile entries each of which define the name and content
#   of individual plugin files which are to be added to the $plugin_dir.
#
# @param rpmrepo_url
#   URL pointing at the RPM file which defines the nagios repo. Note that this
#   only provides packages for x86_64 systems and will have a default value for
#   RedHat 7 and 8 family systems.
#
# Authors
# -------
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
# Phil DeMonaco <phil@demona.co>
#
# Copyright
# ---------
#
# Copyright 2017 Ger Apeldoorn, unless otherwise noted.
#
class ncpa (
  String $community_string,
  Boolean $manage_repo                   = false,
  Boolean $manage_firewall               = false,
  Stdlib::Port $port                     = 5693,
  Stdlib::AbsolutePath $install_dir      = undef,
  String $plugin_dir                     = 'plugins/',
  Array[Ncpa::PluginFile] $plugin_files  = [],
  Optional[Stdlib::HTTPUrl] $rpmrepo_url = undef,
) {

  contain ncpa::install
  contain ncpa::config
  contain ncpa::service

  Class['ncpa::install']
  -> Class['ncpa::config']
  ~> Class['ncpa::service']
}
