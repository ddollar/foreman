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

  describe "exporting to the filesystem" do
    it do
      upstart.export("/tmp/init")
  
      File.read("/tmp/init/app.conf").should         == example_export_file("upstart/app-1.conf")
      File.read("/tmp/init/app-alpha.conf").should   == example_export_file("upstart/app-alpha.conf")
      File.read("/tmp/init/app-alpha-1.conf").should == example_export_file("upstart/app-alpha-1.conf")
      File.read("/tmp/init/app-alpha-2.conf").should == example_export_file("upstart/app-alpha-2.conf")
      File.read("/tmp/init/app-bravo.conf").should   == example_export_file("upstart/app-bravo.conf")
      File.read("/tmp/init/app-bravo-1.conf").should == example_export_file("upstart/app-bravo-1.conf")
    end

    it "with --start-on-boot" do
      upstart.export("/tmp/init", :start_on_boot => true)

      File.read("/tmp/init/app.conf").should == example_export_file("upstart/app-2.conf")
    end
  end
end
