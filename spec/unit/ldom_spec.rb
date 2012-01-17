#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "ldom fact" do
  before :each do
    # explicitly load ldom facts.
    ldom_v1 = "VERSION 1.0
DOMAINROLE|impl=LDoms|control=true|io=true|service=true|root=true
DOMAINNAME|name=primary
DOMAINUUID|uuid=8e0d6ec5-cd55-e57f-ae9f-b4cc050999a4
DOMAINCONTROL|name=san-t2k-6
DOMAINCHASSIS|serialno=0704RB0280"

    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("virtinfo -ap").returns(ldom_v1)
    Facter.collection.loader.load(:ldom)
  end

  # http://docs.oracle.com/cd/E23824_01/html/821-1462/virtinfo-1m.html
  #
  # The parseable output for Logical Domains (LDoms) has the following format:
  #
  # VERSION 1.0
  # DOMAINROLE|impl=LDoms|control={true|false}|
  #     io={true|false}|service={true|false}|
  #     root={true|false}
  # DOMAINNAME|name=domain-name
  # DOMAINUUID|uuid=uuid
  # DOMAINCONTROL|name=control-domain-nodename
  # DOMAINCHASSIS|serialno=serial-no

  it "should return correct impl on version 1.0" do
    Facter.fact(:ldom_domainrole_impl).value.should == "LDoms"
  end

  it "should return correct control on version 1.0" do
    Facter.fact(:ldom_domainrole_control).value.should == "true"
  end

  it "should return correct io on version 1.0" do
    Facter.fact(:ldom_domainrole_io).value.should == "true"
  end

  it "should return correct service on version 1.0" do
    Facter.fact(:ldom_domainrole_service).value.should == "true"
  end

  it "should return correct root on version 1.0" do
    Facter.fact(:ldom_domainrole_root).value.should == "true"
  end

  it "should return correct domain name on version 1.0" do
    Facter.fact(:ldom_domainname).value.should == "primary"
  end

  it "should return correct uuid on version 1.0" do
    Facter.fact(:ldom_domainuuid).value.should == "8e0d6ec5-cd55-e57f-ae9f-b4cc050999a4"
  end

  it "should return correct ldomcontrol on version 1.0" do
    Facter.fact(:ldom_domaincontrol).value.should == "san-t2k-6"
  end

  it "should return correct serial on version 1.0" do
    Facter.fact(:ldom_domainchassis).value.should == "0704RB0280"
  end

  it "should return correct virtual on version 1.0" do
    Facter.fact(:virtual).value.should == "LDoms"
  end
end
