require "spec_helper"
require "foreman/engine"
require "foreman/export/systemd"
require "tmpdir"

describe Foreman::Export::Systemd, :fakefs do
  let(:procfile)  { write_procfile("/tmp/app/Procfile") }
  let(:formation) { nil }
  let(:engine)    { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)   { Hash.new }
  let(:systemd)   { Foreman::Export::Systemd.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("systemd") }
  before(:each) { stub(systemd).say }

  it "exports to the filesystem" do
    systemd.export

    File.read("/tmp/init/app.target").should          == example_export_file("systemd/app.target")
    File.read("/tmp/init/app-alpha.target").should    == example_export_file("systemd/app-alpha.target")
    File.read("/tmp/init/app-alpha-1.service").should == example_export_file("systemd/app-alpha-1.service")
    File.read("/tmp/init/app-bravo.target").should    == example_export_file("systemd/app-bravo.target")
    File.read("/tmp/init/app-bravo-1.service").should == example_export_file("systemd/app-bravo-1.service")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.target")
    mock(FileUtils).rm("/tmp/init/app-alpha.target")
    mock(FileUtils).rm("/tmp/init/app-alpha-1.service")
    mock(FileUtils).rm("/tmp/init/app-bravo.target")
    mock(FileUtils).rm("/tmp/init/app-bravo-1.service")
    mock(FileUtils).rm("/tmp/init/app-foo-bar.target")
    mock(FileUtils).rm("/tmp/init/app-foo-bar-1.service")
    mock(FileUtils).rm("/tmp/init/app-foo_bar.target")
    mock(FileUtils).rm("/tmp/init/app-foo_bar-1.service")

    systemd.export
    systemd.export
  end

  it "includes environment variables" do
    engine.env['KEY'] = 'some "value"'
    systemd.export
    File.read("/tmp/init/app-alpha-1.service").should =~ /KEY=some "value"$/
  end

  context "with a formation" do
    let(:formation) { "alpha=2" }

    it "exports to the filesystem with concurrency" do
      systemd.export

      File.read("/tmp/init/app.target").should             == example_export_file("systemd/app.target")
      File.read("/tmp/init/app-alpha.target").should       == example_export_file("systemd/app-alpha.target")
      File.read("/tmp/init/app-alpha-1.service").should    == example_export_file("systemd/app-alpha-1.service")
      File.read("/tmp/init/app-alpha-2.service").should    == example_export_file("systemd/app-alpha-2.service")
      File.exists?("/tmp/init/app-bravo-1.service").should == false
    end
  end

  context "with alternate templates" do
    let(:template) { "/tmp/alternate" }
    let(:options)  { { :app => "app", :template => template } }

    before do
      FileUtils.mkdir_p template
      File.open("#{template}/master.target.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      systemd.export
      File.read("/tmp/init/app.target").should == "alternate_template\n"
    end
  end

  context "with alternate templates from home dir" do

    before do
      FileUtils.mkdir_p File.expand_path("~/.foreman/templates/systemd")
      File.open(File.expand_path("~/.foreman/templates/systemd/master.target.erb"), "w") do |file|
        file.puts "default_alternate_template"
      end
    end

    it "can export with alternate template files" do
      systemd.export
      File.read("/tmp/init/app.target").should == "default_alternate_template\n"
    end
  end

end
