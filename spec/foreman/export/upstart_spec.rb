require "spec_helper"
require "foreman/engine"
require "foreman/export/upstart"
require "tmpdir"

describe Foreman::Export::Upstart, :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:options)  { Hash.new }
  let(:upstart)  { Foreman::Export::Upstart.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("upstart") }
  before(:each) { stub(upstart).say }

  it "exports to the filesystem" do
    upstart.export

    File.read("/tmp/init/app.conf").should         == example_export_file("upstart/app.conf")
    File.read("/tmp/init/app-alpha.conf").should   == example_export_file("upstart/app-alpha.conf")
    File.read("/tmp/init/app-alpha-1.conf").should == example_export_file("upstart/app-alpha-1.conf")
    File.read("/tmp/init/app-bravo.conf").should   == example_export_file("upstart/app-bravo.conf")
    File.read("/tmp/init/app-bravo-1.conf").should == example_export_file("upstart/app-bravo-1.conf")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.conf")
    mock(FileUtils).rm("/tmp/init/app-alpha.conf")
    mock(FileUtils).rm("/tmp/init/app-alpha-1.conf")
    mock(FileUtils).rm("/tmp/init/app-bravo.conf")
    mock(FileUtils).rm("/tmp/init/app-bravo-1.conf")

    upstart.export
    upstart.export
  end

  it "quotes and escapes environment variables" do
    engine.environment['KEY'] = 'd"\|d'
    upstart.export
    File.read("/tmp/init/app-alpha-1.conf").should include('KEY="d\"\\\\|d"')
  end

  context "with concurrency" do
    let(:options) { Hash[:concurrency => "alpha=2"] }

    it "exports to the filesystem with concurrency" do
      upstart.export

      File.read("/tmp/init/app.conf").should            == example_export_file("upstart/app.conf")
      File.read("/tmp/init/app-alpha.conf").should      == example_export_file("upstart/app-alpha.conf")
      File.read("/tmp/init/app-alpha-1.conf").should    == example_export_file("upstart/app-alpha-1.conf")
      File.read("/tmp/init/app-alpha-2.conf").should    == example_export_file("upstart/app-alpha-2.conf")
      File.exists?("/tmp/init/app-bravo-1.conf").should == false
    end
  end

  context "with alternate templates" do
    let(:template_root) { "/tmp/alternate" }
    let(:upstart) { Foreman::Export::Upstart.new("/tmp/init", engine, :template => template_root) }

    before do
      FileUtils.mkdir_p template_root
      File.open("#{template_root}/master.conf.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      upstart.export

      File.read("/tmp/init/app.conf").should == "alternate_template\n"
    end
  end

  context "with alternate templates from home dir" do
    let(:default_template_root) {File.expand_path("#{ENV['HOME']}/.foreman/templates")}

    before do
      ENV['_FOREMAN_SPEC_HOME'] = ENV['HOME']
      ENV['HOME'] = "/home/appuser"
      FileUtils.mkdir_p default_template_root
      File.open("#{default_template_root}/master.conf.erb", "w") { |f| f.puts "default_alternate_template" }
    end

    after do
      ENV['HOME'] = ENV.delete('_FOREMAN_SPEC_HOME')
    end

    it "can export with alternate template files" do
      upstart.export

      File.read("/tmp/init/app.conf").should == "default_alternate_template\n"
    end
  end

end
