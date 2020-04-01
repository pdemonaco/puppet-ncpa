# @summary Implementation detail, installs packages
class ncpa::install (
  Boolean $manage_repo                   = $ncpa::manage_repo,
  String $package_version                = $ncpa::package_version,
  Optional[Stdlib::HTTPUrl] $rpmrepo_url = $ncpa::rpmrepo_url,
  Optional[String] $package_source       = $ncpa::package_source,
){
  # It all hinges on the kernel type...
  case $facts['kernel'] {
    'Linux': {
      if $manage_repo {
        package { 'nagios-repo':
          ensure   => 'present',
          source   => $rpmrepo_url,
          provider => 'rpm',
          before   => Package['ncpa'],
        }
      }

      package { 'ncpa':
        ensure  => $package_version,
      }
    }
    'windows': {

      package { 'NCPA':
        ensure          => $package_version,
        source          => $package_source,
        install_options => ['/S'],
      }
    }
    default: {}
  }
}
