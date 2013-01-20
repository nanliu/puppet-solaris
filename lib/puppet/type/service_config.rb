module Puppet
  newtype(:service_config) do

    @doc = "Manages smf configuration on Solaris 11.

      Solaris 11 and OpenSolaris have moved a lot of configuration aspects
      from plaintext files to SMF configuration. The `service_config` type
      can be used to set these options with puppet.  One serive config is
      identified by a service identifier (FMRI) and a property name.

      The title of a `service_config` resource can either be the combination
      of a fmri and a property name in the format `<fmri>:<property>` or can
      be just the property name.  In the latter case you have to provider
      the fmri as a resource parameter.

      E.g. to set the nameserver of your DNS client to `10.0.0.1` and
      `10.0.0.2` you can either write

          service_config { 'network/dns/client:config/nameserver':
            ensure => [ '10.0.0.1', '10.0.0.2' ],
            type   => net_address,
          }

      or you can write

          service_config { 'config/nameserver':
            ensure => [ '10.0.0.1', '10.0.0.2' ],
            fmri   => 'network/dns/client',
            type   => net_address,
          }

      Be aware that in both cases the resource title has to be unique.

      Valid values to `ensure` are either a single value, an array or the
      value `absent` when you want to make sure the specified property is
      absent."

    def self.title_patterns
      [
        # pattern to parse <fmri>:<prop>
        [
          /^(.*):(.*)$/,
          [
            [:fmri, lambda{|x| x} ],
            [:prop, lambda{|x| x} ]
          ]
        ],
        # pattern to parse <prop>
        [
          /^(.*)$/,
          [
            [:prop, lambda{|x| x}]
          ]
        ]
      ]
    end

    def name
      # I am not sure if puppet relies on the resource having a name.
      # In general the name is the value of the namevar of the resource
      # Because we use multiple namevars (fmri and prop) this is not going
      # to work, so I overwrite the method here. The type may as well work
      # without this method but you knows...
      "#{self[:fmri]}:#{self[:prop]}"
    end

    newparam(:fmri) do
      desc "The name of the service you want to configure, e.g.
        `svc:/system/keymap:default`"

      isnamevar
    end

    newparam(:prop) do
      desc "The name of the property you want to configure, e.g.
        `keymap/layout`"

      isnamevar
    end

    newparam(:type) do
      desc "The type of the property. This is important when changing a setting"

      newvalues :astring
      newvalues :boolean
      newvalues :integer, :count, :time
      newvalues :net_address, :net_address_v4, :net_address_v6
    end

    newproperty(:ensure, :array_matching => :all) do
      desc "The desired value of the property. You can either specify a
        single value, an array, or the special string `absent`, if you want
        to remove a property"

      newvalues :absent
      newvalues /.*/

      def insync?(is)
        is == @should
      end
    end

  end
end
