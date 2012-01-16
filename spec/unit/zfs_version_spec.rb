#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "zfs_version fact" do

  # http://blogs.oracle.com/bobn/entry/live_upgrade_and_zfs_versioning
  #
  # Solaris Release ZPOOL Version ZFS Version
  # Solaris 10 10/08 (u6) 10  3
  # Solaris 10 5/09 (u7)  10  3
  # Solaris 10 10/09 (u8) 15  4
  # Solaris 10 9/10 (u9)  22  4
  # Solaris 10 8/11 (u10) 29  5
  # Solaris 11 11/11 (ga) 33  5

  solaris_10 = "The following filesystem versions are supported:

VER  DESCRIPTION
---  --------------------------------------------------------
 1   Initial ZFS filesystem version
 2   Enhanced directory entries
 3   Case insensitive and SMB credentials support

For more information on a particular version, including supported releases,
see the ZFS Administration Guide."

  solaris_11 = "The following filesystem versions are supported:

VER  DESCRIPTION
---  --------------------------------------------------------
 1   Initial ZFS filesystem version
 2   Enhanced directory entries
 3   Case insensitive and SMB credentials support
 4   userquota, groupquota properties
 5   System attributes

For more information on a particular version, including supported releases,
see the ZFS Administration Guide."

  it "should return correct version on Solaris 10" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(solaris_10)

    Facter.fact(:zfs_version).value.should == "3"
  end

  it "should return correct version on Solaris 11" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(solaris_11)

    Facter.fact(:zfs_version).value.should == "5"
  end

  it "should not run on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")

    Facter.fact(:zfs_version).value.should == nil
  end
end
