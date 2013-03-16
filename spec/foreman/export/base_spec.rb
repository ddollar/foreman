require "spec_helper"
require "foreman/engine"
require "foreman/export"

describe "Foreman::Export::Base", :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:location) { "/tmp/init" }
  let(:engine)   { Foreman::Engine.new().load_procfile(procfile) }
  let(:subject)  { Foreman::Export::Base.new(location, engine) }

  it "has a say method for displaying info" do
    mock(subject).puts("[foreman export] foo")
    subject.send(:say, "foo")
  end

  it "raises errors as a Foreman::Export::Exception" do
    lambda { subject.send(:error, "foo") }.should raise_error(Foreman::Export::Exception, "foo")
  end
end
