# @summary Manages Nagios Cross-Platform Agent on RedHat family systems
#
# @param community_string
#   The community string that the agent will use to authenticate inbound
#   connections.
#
# @param version
#   When specified, the package manager will attempt to install this version if
#   possible.
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
  Optional[Stdlib::HTTPUrl] $rpmrepo_url = undef,
) {

  contain ncpa::install
  contain ncpa::config
  contain ncpa::service

  Class['ncpa::install']
  -> Class['ncpa::config']
  ~> Class['ncpa::service']
}
