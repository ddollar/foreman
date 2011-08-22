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

  context "with alternate templates" do
    let(:template_root) { "/tmp/alternate" }

    before do
      FileUtils.mkdir_p template_root
      File.open("#{template_root}/master.conf.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      upstart.export("/tmp/init", :template => template_root)

      File.read("/tmp/init/app.conf").should == "alternate_template\n"
    end
  end

  context "with alternate templates from home dir" do
    let(:default_template_root) {File.expand_path("~/.foreman/templates")}

    before do
      FileUtils.mkdir_p default_template_root
      File.open("#{default_template_root}/master.conf.erb", "w") { |f| f.puts "default_alternate_template" }
    end

    it "can export with alternate template files" do
      upstart.export("/tmp/init")

      File.read("/tmp/init/app.conf").should == "default_alternate_template\n"
    end
  end

end
