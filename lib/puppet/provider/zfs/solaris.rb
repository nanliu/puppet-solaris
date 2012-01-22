Puppet::Type.type(:zfs).provide(:solaris) do
  desc "Provider for Solaris zfs."

  commands :zfs => "/usr/sbin/zfs"
  defaultfor :operatingsystem => :solaris

  def self.instances
    zfs_list = zfs(:list).split("\n")
    key = zfs_list.shift.split

    zfs_list = zfs_list.collect{ |l| l.split }
    zfs_list.collect do |l|
      new(:name => l[key.index('NAME')])
    end
  end

  def add_properties
    properties = []
    Puppet::Type.type(:zfs).validproperties.each do |property|
      next if property == :ensure
      if value = @resource[property] and value != ""
        properties << "-o" << "#{property}=#{value}"
      end
    end
    properties
  end

  def create
    zfs *([:create] + add_properties + [@resource[:name]])
  end

  def destroy
    zfs(:destroy, @resource[:name])
  end

  def exists?
    if zfs(:list).split("\n").detect { |line| line.split("\s")[0] == @resource[:name] }
      true
    else
      false
    end
  end

  [:aclinherit, :aclmode, :atime, :canmount, :checksum, :compression, :copies, :devices, :exec, :logbias, :mountpoint, :nbmand, :primarycache, :quota, :readonly, :recordsize, :refquota, :refreservation, :reservation, :secondarycache, :setuid, :shareiscsi, :sharenfs, :sharesmb, :snapdir, :version, :volsize, :vscan, :xattr, :zoned, :vscan].each do |field|
    define_method(field) do
      begin
        zfs(:get, "-H", "-o", "value", field, @resource[:name]).strip
      rescue Exception => e
        Puppet.debug("Puppet::ZFS: unsupported attribute: #{field}")
        :undef
      end
    end

    define_method(field.to_s + "=") do |should|
      zfs(:set, "#{field}=#{should}", @resource[:name])
    end
  end

end

