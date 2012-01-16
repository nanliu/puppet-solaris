#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "zpool_version fact" do

  # http://blogs.oracle.com/bobn/entry/live_upgrade_and_zfs_versioning
  #
  # Solaris Release ZPOOL Version ZFS Version
  # Solaris 10 10/08 (u6) 10  3
  # Solaris 10 5/09 (u7)  10  3
  # Solaris 10 10/09 (u8) 15  4
  # Solaris 10 9/10 (u9)  22  4
  # Solaris 10 8/11 (u10) 29  5
  # Solaris 11 11/11 (ga) 33  5

  solaris_10 = "This system is currently running ZFS pool version 22.

The following versions are supported:

VER  DESCRIPTION
---  --------------------------------------------------------
 1   Initial ZFS version
 2   Ditto blocks (replicated metadata)
 3   Hot spares and double parity RAID-Z
 4   zpool history
 5   Compression using the gzip algorithm
 6   bootfs pool property
 7   Separate intent log devices
 8   Delegated administration
 9   refquota and refreservation properties
 10  Cache devices
 11  Improved scrub performance
 12  Snapshot properties
 13  snapused property
 14  passthrough-x aclinherit
 15  user/group space accounting
 16  stmf property support
 17  Triple-parity RAID-Z
 18  Snapshot user holds
 19  Log device removal
 20  Compression using zle (zero-length encoding)
 21  Reserved
 22  Received properties

For more information on a particular version, including supported releases,
see the ZFS Administration Guide."

  solaris_11 = "zpool upgrade -v
This system is currently running ZFS pool version 33.

The following versions are supported:

VER  DESCRIPTION
---  --------------------------------------------------------
 1   Initial ZFS version
 2   Ditto blocks (replicated metadata)
 3   Hot spares and double parity RAID-Z
 4   zpool history
 5   Compression using the gzip algorithm
 6   bootfs pool property
 7   Separate intent log devices
 8   Delegated administration
 9   refquota and refreservation properties
 10  Cache devices
 11  Improved scrub performance
 12  Snapshot properties
 13  snapused property
 14  passthrough-x aclinherit
 15  user/group space accounting
 16  stmf property support
 17  Triple-parity RAID-Z
 18  Snapshot user holds
 19  Log device removal
 20  Compression using zle (zero-length encoding)
 21  Deduplication
 22  Received properties
 23  Slim ZIL
 24  System attributes
 25  Improved scrub stats
 26  Improved snapshot deletion performance
 27  Improved snapshot creation performance
 28  Multiple vdev replacements
 29  RAID-Z/mirror hybrid allocator
 30  Encryption
 31  Improved 'zfs list' performance
 32  One MB blocksize
 33  Improved share support

For more information on a particular version, including supported releases,
see the ZFS Administration Guide."

  it "should return correct version on Solaris 10" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(solaris_10)

    Facter.fact(:zpool_version).value.should == "22"
  end

  it "should return correct version on Solaris 11" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(solaris_11)

    Facter.fact(:zpool_version).value.should == "33"
  end

  it "should not run on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")

    Facter.fact(:zpool_version).value.should == nil
  end
end
