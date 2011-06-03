require "spec_helper"
require "foreman/engine"
require "foreman/export/upstart"
require "tmpdir"

describe Foreman::Export::Upstart do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine) { Foreman::Engine.new(procfile) }
  let(:upstart) { Foreman::Export::Upstart.new(engine) }

  before(:each) { load_export_templates_into_fakefs("upstart") }
  before(:each) { stub(upstart).say }

  it "exports to the filesystem" do
    upstart.export("/tmp/init")

    File.read("/tmp/init/app.conf").should         == example_export_file("upstart/app.conf")
    File.read("/tmp/init/app-alpha.conf").should   == example_export_file("upstart/app-alpha.conf")
    File.read("/tmp/init/app-alpha-1.conf").should == example_export_file("upstart/app-alpha-1.conf")
    File.read("/tmp/init/app-alpha-2.conf").should == example_export_file("upstart/app-alpha-2.conf")
    File.read("/tmp/init/app-bravo.conf").should   == example_export_file("upstart/app-bravo.conf")
    File.read("/tmp/init/app-bravo-1.conf").should == example_export_file("upstart/app-bravo-1.conf")
  end
end
