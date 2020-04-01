# Nagios Cross-Platform Agent

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Install the Nagios Cross-Platform Agent on Linux and Windows.

## Usage

### Linux - Minimum

#### Hiera


```puppet
include ncpa
```

```yaml
ncpa::community_string: 123413242134
```

#### Puppet

```puppet
class { 'ncpa':
  community_string => '123413242134',
}
```

### Windows - Minimum

This install assumes the NCPA binary has been distributed to the temp directory on the target node.

#### Hiera

```puppet
include ncpa
```

```yaml
ncpa::community_string: 123413242134
ncpa::package_source: 'c:\temp\ncpa.exe'
```

#### Puppet

```puppet
class { 'ncpa':
  community_string => '123413242134',
  package_source   => 'c:\temp\ncpa.exe',
}
```

### Linux - Full

The following yaml and puppet code examples demonstrate a full configuration of the module on a linux host.

Couple notes:
* this assumes the OS is RedHat 7 or 8 (CentOS or RHEL) as the `$rpmrepo_url` value is sourced from the module hiera.
* The puppet URL source assumes you have a [custom mount point](https://puppet.com/docs/puppet/latest/file_serving.html) called module_specific configured via [fileserver.conf](https://puppet.com/docs/puppet/latest/config_file_fileserver.html) (possibly on your puppet-master).


#### Hiera

```yaml
ncpa::community_string: 123413242134
ncpa::manage_repo: true
ncpa::manage_firewall: true
ncpa::port: 13000
ncpa::plugin_files:
  - name: 'plugin1.py'
    source: 'puppet:///module_specific/ncpa/plugin1/plugin1.py'
  - name: 'plugin2.sh'
    source: 'https://plugins.com/plugin2/plugin2.sh'
  - name: 'plugin3.py'
    source: '/usr/local/bin/plugin3.py'
```

#### Puppet

```puppet
class { 'ncpa':
  community_string => 123413242134,
  manage_repo      => true,
  manage_firewall  => true,
  port             => 13000,
  plugin_files     => [
    {
      name =>'plugin1.py',
      source => 'puppet:///module_specific/ncpa/plugin1/plugin1.py',
    },
    {
      name =>'plugin2.sh',
      source => 'https://plugins.com/plugin2/plugin2.sh',
    },
    {
      name =>'plugin3.py',
      source => '/usr/local/bin/plugin3.py',
    },
  ],
}

```



## Limitations

* Currently only RedHat family operating systems can automatically add the NCPA repository. This package will install NCPA on other distros if the package is known.
* `$plugin_dir` is assumed to be a subdirectory of `$install_dir`. Neither of these values should really be changed.

## Development

Feel free to submit a PR

## Release Notes

See the [changelog](./CHANGELOG.md).
