require "spec_helper"
require "foreman/engine"
require "foreman/export/upstart"

describe Foreman::Export::Upstart do
  let(:engine) { Foreman::Engine.new(write_procfile) }
  let(:upstart) { Foreman::Export::Upstart.new(engine) }

  before(:each) { load_export_templates_into_fakefs("upstart") }
  before(:each) { stub(upstart).say }

  it "exports to the filesystem" do
    upstart.export("/tmp/init")

    File.read("/tmp/init/foreman.conf").should         == example_export_file("upstart/foreman.conf")
    File.read("/tmp/init/foreman-alpha.conf").should   == example_export_file("upstart/foreman-alpha.conf")
    File.read("/tmp/init/foreman-alpha-1.conf").should == example_export_file("upstart/foreman-alpha-1.conf")
    File.read("/tmp/init/foreman-alpha-2.conf").should == example_export_file("upstart/foreman-alpha-2.conf")
    File.read("/tmp/init/foreman-bravo.conf").should   == example_export_file("upstart/foreman.bravo.conf")
    File.read("/tmp/init/foreman-bravo-1.conf").should == example_export_file("upstart/foreman-bravo-1.conf")
  end
end
