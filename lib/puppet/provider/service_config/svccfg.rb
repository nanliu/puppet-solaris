require 'strscan'
Puppet::Type.type(:service_config).provide(:svccfg) do
  desc "Manages smf configuration with svccfg"

  commands :svccfg => '/usr/sbin/svccfg'

  defaultfor :operatingsystem => :solaris

  def ensure
    result = [:absent]
    svccfg('-s', resource[:fmri], :listprop, resource[:prop]).each_line do |line|
      next if /^\s*$/.match(line) # ignore empty lines
      next if /^\s*#/.match(line) # ignore comments
      name, type, value = line.chomp.split(/\s+/,3)
      scanner = StringScanner.new(value)
      result = []
      while !scanner.eos?
        scanner.skip(/\s+/)
        # TODO: This will not work if the value itself contains escaped
        # characters such as \"
        if token = scanner.scan(/".*?"|\S+/)
          token.gsub!(/"(.*)"/, '\1')
          result << token
        else
          raise Puppet::Error, "Unable to parse value #{value}"
        end
      end
      break
    end
    result
  end

  def ensure=(new_value)
    new_value = [new_value] unless new_value.is_a? Array
    if new_value == [:absent]
      svccfg('-s', resource[:fmri], :delprop, resource[:prop])
    else
      quoted_values = case resource[:type]
      when :astring
        new_value.map {|s| "\"#{s}\"" }
      else
        new_value
      end
      argument = if quoted_values.size == 1
        quoted_values.first
      else
        "(#{quoted_values.join(' ')})"
      end

      svccfg('-s', resource[:fmri], :setprop, resource[:prop], '=', "#{resource[:type]}:", argument)
    end
  end

end
