#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:service_config) do

  let :providerclass do
    described_class.provider(:simple) { mk_resource_methods }
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

  it "should have fmri as a keyattribute" do
    described_class.key_attributes.should include :fmri
  end

  it "should have prop as a keyattribute" do
    described_class.key_attributes.should include :prop
  end

  describe "title splitting" do
    [
      {:fmri => 'svc:/system/keymap:default', :prop => 'keymap/layout'},
      {:fmri => 'network/dns/client', :prop => 'config/nameserver'},
      {:fmri => 'svc:/network/dns/client', :prop => 'config/value_authorization'}
    ].each do |input|
      input[:title] = "#{input[:fmri]}:#{input[:prop]}"
      it "should correctly split #{input[:title]} into frmi and property" do
        regex = described_class.title_patterns[0][0]
        regex.match(input[:title]).captures.should == [ input[:fmri], input[:prop] ]
      end
    end

    it "should work with only the property as a title" do
      regex = described_class.title_patterns[1][0]
      regex.match('config/value_authorization').captures.should == [ 'config/value_authorization' ]
    end
  end

  describe "when validating attributes" do
    [:fmri, :prop, :type, :provider].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end

    [:ensure].each do |property|
      it "should have #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end

  describe "when validating values" do
    describe "for type" do
      [:astring, :count, :net_address_v4, :net_address_v6, :net_address, :boolean, :integer, :time].each do |type|
        it "should support #{type} as value" do
          expect { described_class.new(title.merge(:type => type, :ensure => 'foo')) }.to_not raise_error
        end
      end
      it "should not support different values" do
        expect { described_class.new(title.merge(:type => :foo, :ensure => 'foo')) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end
    describe "for ensure" do
      it "should support a single value" do
        expect { described_class.new(title.merge(:ensure => 'foo')) }.to_not raise_error
      end

      it "should support an array" do
        expect { described_class.new(title.merge(:ensure => ['foo', 'bar'])) }.to_not raise_error
      end

      it "should support absent" do
        expect { described_class.new(title.merge(:ensure => :absent)) }.to_not raise_error
      end
    end
  end
end
