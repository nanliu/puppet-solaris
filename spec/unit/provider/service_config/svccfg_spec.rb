#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:service_config).provider(:svccfg) do

  let :provider do
    described_class.new
  end

  let :fmri do
    'svc:/system/keymap:default'
  end

  let :prop do
    'keymap/layout'
  end

  let :title do
    {:title => "#{fmri}:#{prop}", :fmri => fmri, :prop => prop}
  end

  describe "#ensure" do
    before :each do
      Puppet::Type.type(:service_config).new(title.merge(:ensure => 'German', :type => :astring, :provider => provider))
    end

    it "should use svccfg to return the current value" do
      provider.expects(:svccfg).with('-s', 'svc:/system/keymap:default', :listprop, 'keymap/layout').returns 'keymap/layout                     astring     German'
      provider.ensure
    end

    it "should get a string value" do
      provider.stubs(:svccfg).returns 'keymap/layout  astring German'
      provider.ensure.should == ['German']
    end

    it "should get a quoted string value" do
      provider.stubs(:svccfg).returns 'config/network              astring             "nis [NOTFOUND=return] files"'
      provider.ensure.should == ['nis [NOTFOUND=return] files']
    end

    it "should get a list of strings" do
      provider.stubs(:svccfg).returns 'config/search astring "example.com" "test.com"'
      provider.ensure.should == ['example.com', 'test.com']
    end

    it "should get a numeric value" do
      provider.stubs(:svccfg).returns 'keymap/kbd_beeper_freq            integer     2000'
      provider.ensure.should == ['2000']
    end

    it "should get a decimal value" do
      provider.stubs(:svccfg).returns 'restarter/start_method_timestamp  time        1358352122.695415000'
      provider.ensure.should == ['1358352122.695415000']
    end

    it "should get a single address" do
      provider.stubs(:svccfg).returns 'config/nameserver          net_address 192.168.0.1'
      provider.ensure.should == ['192.168.0.1']
    end

    it "should get a list of addresses" do
      provider.stubs(:svccfg).returns 'config/nameserver net_address 192.168.0.1 10.0.0.1'
      provider.ensure.should == ['192.168.0.1', '10.0.0.1']
    end

    it "should get :absent when property is not present" do
      provider.stubs(:svccfg).returns "\n\n"
      provider.ensure.should == [:absent]
    end
  end

  describe "#ensure=" do
    before :each do
      provider.stubs(:svcadm)
    end

    describe "and type is astring" do
      before :each do
        Puppet::Type.type(:service_config).new(title.merge(:type => :astring, :ensure => 'old value', :provider => provider))
      end

      it "should remove the property" do
        provider.expects(:svccfg).with('-s', fmri, :delprop, prop)
        provider.ensure = [:absent]
      end

      it "should set a single string" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', '"foo"')
        provider.ensure = ['foo']
      end

      it "should set a single string with spaces" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', %q{"foo bar"})
        provider.ensure = ['foo bar']
      end

      it "should set a list of strings" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', %q{("foo" "bar")})
        provider.ensure = [ 'foo', 'bar' ]
      end

      it "should set a list of strings with spaces" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'astring:', %q{("foo" "bar baz")})
        provider.ensure = [ 'foo', 'bar baz' ]
      end
    end

    describe "and type is net_address" do
      before :each do
        Puppet::Type.type(:service_config).new(title.merge(:type => :net_address, :ensure => '10.0.0.1', :provider => provider))
      end

      it "should remove the property" do
        provider.expects(:svccfg).with('-s', fmri, :delprop, prop)
        provider.ensure = [:absent]
      end

      it "should set a single address" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'net_address:', %q{127.0.0.1})
        provider.ensure = ['127.0.0.1']
      end

      it "should set a list of addresses" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'net_address:', %q{(10.0.0.141 10.0.0.142)})
        provider.ensure = [ '10.0.0.141', '10.0.0.142' ]
      end
    end

    describe "and type is integer" do
      before :each do
        Puppet::Type.type(:service_config).new(title.merge(:type => :integer, :ensure => '10', :provider => provider))
      end

      it "should remove the property" do
        provider.expects(:svccfg).with('-s', fmri, :delprop, prop)
        provider.ensure = [:absent]
      end

      it "should set a single value" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'integer:', '500')
        provider.ensure = ['500']
      end

      it "should set a list of values" do
        provider.expects(:svccfg).with('-s', fmri, :setprop, prop, '=', 'integer:', '(500 600)')
        provider.ensure = [ '500', '600' ]
      end
    end
  end

  describe "#flush" do
    it "should refresh the service" do
      Puppet::Type.type(:service_config).new(title.merge(:type => :integer, :ensure => '10', :provider => provider))
      provider.expects(:svcadm).with(:refresh,'svc:/system/keymap:default')
      provider.flush
    end
  end
end
