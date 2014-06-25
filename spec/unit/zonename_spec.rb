#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "zonename fact" do

  it "should return global zone" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")

    if defined?(Facter::Core)
      Facter::Core::Execution.expects(:execute).with("zonename", {:on_fail => nil}).returns('global')
    else
      Facter::Util::Resolution.stubs(:exec).with("zonename").returns('global')
    end

    Facter.value(:zonename).should == "global"
  end
end
