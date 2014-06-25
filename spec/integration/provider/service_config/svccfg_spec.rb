#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:service_config).provider(:svccfg), '(integration)' do

  before :each do
    described_class.stubs(:suitable?).returns true
  end

  let :fmri do
    'svc:/network/dns/client'
  end

  let :prop do
    'config/search'
  end

  let :default_options do
    {
      :title  => "#{fmri}:#{prop}",
      :fmri   => fmri,
      :prop   => prop,
      :type   => :astring
    }
  end

  let :resource_singlevalue do
    Puppet::Type.type(:service_config).new(default_options.merge(:ensure => 'example.com'))
  end

  let :resource_listone do
    Puppet::Type.type(:service_config).new(default_options.merge(:ensure => ['test.com']))
  end

  let :resource_listthree do
    Puppet::Type.type(:service_config).new(default_options.merge(:ensure => ['example.com', 'example.de', 'test.com']))
  end

  let :resource_absent do
    Puppet::Type.type(:service_config).new(default_options.merge(:ensure => :absent))
  end

  def run_in_catalog(resource)
    catalog = Puppet::Resource::Catalog.new
    catalog.host_config = false
    resource.expects(:err).never
    catalog.add_resource resource
    catalog.apply
  end

  describe "ensure is a single value" do
    it "should do nothing if value is in sync" do
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring example.com\n")
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"example.com"').never
      resource_singlevalue.provider.expects(:svcadm).with(:refresh, fmri).never
      run_in_catalog(resource_singlevalue)
    end

    it "should create the property if currently absent" do
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("\n\n")
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"example.com"')
      resource_singlevalue.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_singlevalue)
    end

    it "should replace a single value" do
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring wrong.com\n")
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"example.com"')
      resource_singlevalue.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_singlevalue)
    end

    it "should replace a list of values" do
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring \"example.com\" \"wrong.com\"\n")
      resource_singlevalue.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"example.com"')
      resource_singlevalue.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_singlevalue)
    end
  end

  describe "ensure is a list of values with one element" do
    it "should do nothing if value is in sync" do
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring test.com\n")
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"test.com"').never
      resource_listone.provider.expects(:svcadm).with(:refresh, fmri).never
      run_in_catalog(resource_listone)
    end

    it "should create the property if currently absent" do
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("\n\n")
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"test.com"')
      resource_listone.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listone)
    end

    it "should replace a single value" do
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring wrong.com\n")
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"test.com"')
      resource_listone.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listone)
    end

    it "should replace a list of values" do
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring \"example.com\" \"wrong.com\"\n")
      resource_listone.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"test.com"')
      resource_listone.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listone)
    end
  end

  describe "ensure is a list of values with more than one element" do
    it "should do nothing if value is in sync" do
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring \"example.com\" \"example.de\" \"test.com\"\n")
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '("example.com" "example.de" "test.com")').never
      resource_listthree.provider.expects(:svcadm).with(:refresh, fmri).never
      run_in_catalog(resource_listthree)
    end

    it "should create the property if currently absent" do
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("\n\n")
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '("example.com" "example.de" "test.com")')
      resource_listthree.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listthree)
    end

    it "should replace a single value" do
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring wrong.com\n")
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '("example.com" "example.de" "test.com")')
      resource_listthree.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listthree)
    end

    it "should replace a list of values" do
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring \"example.com\" \"test.com\" \"example.de\"\n")
      resource_listthree.provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '("example.com" "example.de" "test.com")')
      resource_listthree.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_listthree)
    end
  end

  describe "ensure is absent" do
    it "should do nothing if property is already absent" do
      resource_absent.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("\n\n")
      resource_absent.provider.expects(:svccfg).never
      resource_absent.provider.expects(:svcadm).with(:refresh, fmri).never
      run_in_catalog(resource_absent)
    end
    it "should remove the property if it has a single value" do
      resource_absent.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring wrong.com\n")
      resource_absent.provider.expects(:svccfg).with('-s', fmri, :delprop, prop)
      resource_absent.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_absent)
    end

    it "should remove the property if it has a list of values" do
      resource_absent.provider.expects(:svccfg).with('-s', fmri, :listprop, prop).returns("config/search astring \"example.com\" \"test.com\" \"example.de\"\n")
      resource_absent.provider.expects(:svccfg).with('-s', fmri, :delprop, prop)
      resource_absent.provider.expects(:svcadm).with(:refresh, fmri)
      run_in_catalog(resource_absent)
    end
  end
end
