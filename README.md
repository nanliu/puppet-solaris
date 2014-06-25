# Puppet Solaris 11 Enhancements

[![Build Status](https://travis-ci.org/nanliu/puppet-solaris.png?branch=master)](https://travis-ci.org/nanliu/puppet-solaris)

Warning: this is a personal experimental project to improve [Puppet](http://www.puppetlabs.com) support for [OpenIndiana](http://openindiana.org/) and Solaris 11 features.

## Overview
This project is intended have a Puppet module to resolve outstanding bugs and add new features for Solaris.

Facter:

* zonename [#1424](http://http://projects.puppetlabs.com/issues/1424)
* ldom [#6682](http://projects.puppetlabs.com/issues/6692)
* zfs_version [#11969](http://projects.puppetlabs.com/issues/11969)

Puppet:

* ips
** support arbitrary output format [#11004](http://projects.puppetlabs.com/issues/11004) Note: the patch does not appear to be backwards compatible
** pkg publisher
* smf
* zfs
* zpool
* zone

Currently existing types provider seems to lack self.instances [#10978](http://projects.puppetlabs.com/issues/10978)

## Usage

Since there are subtle difference in the command output across Solaris versions, it would be benificial to test the code here in as Solaris 9/10/11 and OpenIndiana.  Please update the tickets above with any issues discovered when testing this module.

## Contribution

The code here have been based on contributions from:

* Martin England
* Stefan Schulte
