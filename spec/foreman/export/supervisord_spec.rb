require "spec_helper"
require "foreman/engine"
require "foreman/export/supervisord"
require "tmpdir"

describe Foreman::Export::Supervisord, :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:options)  { Hash.new }
  let(:supervisord)  { Foreman::Export::Supervisord.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("supervisord") }
  before(:each) { stub(supervisord).say }

  it "exports to the filesystem" do
    supervisord.export

    File.read("/tmp/init/app.conf").should         == example_export_file("supervisord/app.conf")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.conf")

    supervisord.export
    supervisord.export
  end

  context "with concurrency" do
    let(:options) { Hash[:concurrency => "alpha=2"] }

    it "exports to the filesystem with concurrency" do
      supervisord.export

      File.read("/tmp/init/app.conf").should            == example_export_file("supervisord/app-alpha-2.conf")
    end
  end

  context "with alternate templates" do
    let(:template_root) { "/tmp/alternate" }
    let(:supervisord) { Foreman::Export::Supervisord.new("/tmp/init", engine, :template => template_root) }

    before do
      FileUtils.mkdir_p template_root
      File.open("#{template_root}/app.conf.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      supervisord.export

      File.read("/tmp/init/app.conf").should == "alternate_template\n"
    end
  end

  context "with alternate templates from home dir" do
    let(:default_template_root) {File.expand_path("#{ENV['HOME']}/.foreman/templates")}

    before do
      ENV['_FOREMAN_SPEC_HOME'] = ENV['HOME']
      ENV['HOME'] = "/home/appuser"
      FileUtils.mkdir_p default_template_root
      File.open("#{default_template_root}/app.conf.erb", "w") { |f| f.puts "default_alternate_template" }
    end

    after do
      ENV['HOME'] = ENV.delete('_FOREMAN_SPEC_HOME')
    end

    it "can export with alternate template files" do
      supervisord.export

      File.read("/tmp/init/app.conf").should == "default_alternate_template\n"
    end
  end

  context "environment export" do
    it "returns the original environment if it contains no comma" do
      supervisord.wrap_environment("production").should == "production"
    end

    it "wrapps the original environment with quotes if it contains a comma" do
      supervisord.wrap_environment("slowqueue,fastqueue").should == '"slowqueue,fastqueue"'
    end
  end

end
