require 'spec_helper'
require 'foreman/procfile'
require 'pathname'
require 'tmpdir'

describe Foreman::Procfile, :fakefs do
  subject { Foreman::Procfile.new }

  it "can load from a file" do
    write_procfile
    subject.load "Procfile"
    subject["alpha"].should == "./alpha"
    subject["bravo"].should == "./bravo"
  end

  it "loads a passed-in Procfile" do
    write_procfile
    procfile = Foreman::Procfile.new("Procfile")
    procfile["alpha"].should   == "./alpha"
    procfile["bravo"].should   == "./bravo"
    procfile["foo-bar"].should == "./foo-bar"
    procfile["foo_bar"].should == "./foo_bar"
  end

  it "can have a process appended to it" do
    subject["charlie"] = "./charlie"
    subject["charlie"].should == "./charlie"
  end

  it "can write to a string" do
    subject["foo"] = "./foo"
    subject["bar"] = "./bar"
    subject.to_s.should == "foo: ./foo\nbar: ./bar"
  end

  it "can write to a file" do
    subject["foo"] = "./foo"
    subject["bar"] = "./bar"
    subject.save "/tmp/proc"
    File.read("/tmp/proc").should == "foo: ./foo\nbar: ./bar\n"
  end

end
