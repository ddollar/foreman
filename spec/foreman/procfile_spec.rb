require 'spec_helper'
require 'foreman/procfile'
require 'pathname'
require 'tmpdir'

describe Foreman::Procfile, :fakefs do
  subject { Foreman::Procfile.new }

  it "can load from a file" do
    write_procfile
    subject.load "Procfile"
    expect(subject["alpha"]).to eq("./alpha")
    expect(subject["bravo"]).to eq("./bravo")
  end

  it "loads a passed-in Procfile" do
    write_procfile
    procfile = Foreman::Procfile.new("Procfile")
    expect(procfile["alpha"]).to   eq("./alpha")
    expect(procfile["bravo"]).to   eq("./bravo")
    expect(procfile["foo-bar"]).to eq("./foo-bar")
    expect(procfile["foo_bar"]).to eq("./foo_bar")
  end

  it "can have a process appended to it" do
    subject["charlie"] = "./charlie"
    expect(subject["charlie"]).to eq("./charlie")
  end

  it "can write to a string" do
    subject["foo"] = "./foo"
    subject["bar"] = "./bar"
    expect(subject.to_s).to eq("foo: ./foo\nbar: ./bar")
  end

  it "can write to a file" do
    subject["foo"] = "./foo"
    subject["bar"] = "./bar"
    subject.save "/tmp/proc"
    expect(File.read("/tmp/proc")).to eq("foo: ./foo\nbar: ./bar\n")
  end

end
