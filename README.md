# Nagios Cross-Platform Agent

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Install the Nagios Cross-Platform Agent on RHEL.

## Usage

```puppet
include ncpa
```

Hiera:
```yaml
ncpa::community_string: 123413242134
```

## Limitations

Currently only works for RHEL.

## Development

Feel free to submit a PR

## Release Notes

See the [changelog](./CHANGELOG.md).
