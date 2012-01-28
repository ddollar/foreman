require "spec_helper"
require "foreman/export/base"

describe "Foreman::Export::Base" do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:location) { "/tmp/init" }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:subject)  { Foreman::Export::Base.new(location, engine) }

  it "has a say method for displaying info" do
    mock(subject).puts("[foreman export] foo")
    subject.send(:say, "foo")
  end

  it "export needs to be overridden" do
    lambda { subject.export }.should raise_error("export method must be overridden")
  end

  it "raises errors as a Foreman::Export::Exception" do
    lambda { subject.send(:error, "foo") }.should raise_error(Foreman::Export::Exception, "foo")
  end
end
