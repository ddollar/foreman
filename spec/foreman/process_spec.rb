require 'spec_helper'
require 'foreman/process'
require 'ostruct'
require 'timeout'
require 'tmpdir'

describe Foreman::Process do

  def run(process, options={})
    rd, wr = IO.method(:pipe).arity.zero? ? IO.pipe : IO.pipe("BINARY")
    process.run(options.merge(:output => wr))
    rd.gets
  end

  describe "#run" do

    it "runs the process" do
      process = Foreman::Process.new(resource_path("bin/test"))
      run(process).should == "testing\n"
    end

    it "can set environment" do
      process = Foreman::Process.new(resource_path("bin/env FOO"), :env => { "FOO" => "bar" })
      run(process).should == "bar\n"
    end

    it "can set per-run environment" do
      process = Foreman::Process.new(resource_path("bin/env FOO"))
      run(process, :env => { "FOO" => "bar "}).should == "bar\n"
    end

    it "can handle env vars in the command" do
      process = Foreman::Process.new(resource_path("bin/echo $FOO"), :env => { "FOO" => "bar" })
      run(process).should == "bar\n"
    end

    it "can handle per-run env vars in the command" do
      process = Foreman::Process.new(resource_path("bin/echo $FOO"))
      run(process, :env => { "FOO" => "bar" }).should == "bar\n"
    end

    it "should output utf8 properly" do
      process = Foreman::Process.new(resource_path("bin/utf8"))
      run(process).should == (Foreman.ruby_18? ? "\xFF\x03\n" : "\xFF\x03\n".force_encoding('binary'))
    end
  end

end
