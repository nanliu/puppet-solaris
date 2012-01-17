if Facter.value(:kernel) == 'SunOS'
  virtinfo = Facter::Util::Resolution.exec('virtinfo -ap')

  virt_array = virtinfo.split("\n").select{|l| l =~ /^DOMAIN/ }.collect{|l| l.split('|')}
  virt_array.each do |x|
    key = x[0]
    value = x[1..x.size]

    case key
    when 'DOMAINROLE'
      value.each do |y|
        k = y.split('=')[0]
        v = y.split('=')[1]
        Facter.add("ldom_domainrole_#{k}") do
          setcode { v }
        end
      end
    else
      Facter.add("ldom_#{key.downcase}") do
        setcode { value.first.split('=')[1] }
      end
    end
  end

  Facter.add("virtual") do
    confine :ldom_domainrole_control => 'true'
    has_weight 10
    setcode do
      Facter.value(:ldom_domainrole_impl)
    end
  end
end
