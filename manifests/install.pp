# @summary Implementation detail, installs packages
class ncpa::install (
  Boolean $manage_repo                   = $ncpa::manage_repo,
  Optional[Stdlib::HTTPUrl] $rpmrepo_url = $ncpa::rpmrepo_url,
){
  if $manage_repo {
    unless($rpmrepo_url) {
      fail('$rpmrepo_url must be provided when \$manage_repo is enabled!')
    }
    package { 'nagios-repo':
      ensure   => 'present',
      source   => $rpmrepo_url,
      provider => 'rpm',
      before   => Package['ncpa'],
    }
  }

  package { 'ncpa':
    ensure  => installed,
  }
}
