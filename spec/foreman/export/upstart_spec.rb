require "spec_helper"
require "foreman/engine"
require "foreman/export/upstart"
require "tmpdir"

describe Foreman::Export::Upstart, :fakefs do
  let(:procfile)  { write_procfile("/tmp/app/Procfile") }
  let(:formation) { nil }
  let(:engine)    { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)   { Hash.new }
  let(:upstart)   { Foreman::Export::Upstart.new("/tmp/init", engine, options) }

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
    mock(FileUtils).rm("/tmp/init/app-foo-bar.conf")
    mock(FileUtils).rm("/tmp/init/app-foo-bar-1.conf")
    mock(FileUtils).rm("/tmp/init/app-foo_bar.conf")
    mock(FileUtils).rm("/tmp/init/app-foo_bar-1.conf")

    upstart.export
    upstart.export
  end

  it "does not delete exported files for similarly named applications" do
    FileUtils.mkdir_p "/tmp/init"

    ["app2", "app2-alpha", "app2-alpha-1"].each do |name|
      path = "/tmp/init/#{name}.conf"
      FileUtils.touch(path)
      dont_allow(FileUtils).rm(path)
    end

    upstart.export
  end

  it "quotes and escapes environment variables" do
    engine.env['KEY'] = 'd"\|d'
    upstart.export
    "foobarfoo".should include "bar"
    File.read("/tmp/init/app-alpha-1.conf").should =~ /KEY=d\\"\\\\\\\|d/
  end

  context "with a formation" do
    let(:formation) { "alpha=2" }

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
    let(:template) { "/tmp/alternate" }
    let(:options)  { { :app => "app", :template => template } }

    before do
      FileUtils.mkdir_p template
      File.open("#{template}/master.conf.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      upstart.export
      File.read("/tmp/init/app.conf").should == "alternate_template\n"
    end
  end

  context "with alternate templates from home dir" do

    before do
      FileUtils.mkdir_p File.expand_path("~/.foreman/templates/upstart")
      File.open(File.expand_path("~/.foreman/templates/upstart/master.conf.erb"), "w") do |file|
        file.puts "default_alternate_template"
      end
    end

    it "can export with alternate template files" do
      upstart.export
      File.read("/tmp/init/app.conf").should == "default_alternate_template\n"
    end
  end

end
