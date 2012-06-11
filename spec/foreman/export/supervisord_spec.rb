require "spec_helper"
require "foreman/engine"
require "foreman/export/supervisord"
require "tmpdir"

describe Foreman::Export::Supervisord, :fakefs do
  let(:procfile)    { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:formation)   { nil }
  let(:engine)      { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)     { Hash.new }
  let(:supervisord) { Foreman::Export::Supervisord.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("supervisord") }
  before(:each) { stub(supervisord).say }

  it "exports to the filesystem" do
    supervisord.export
    File.read("/tmp/init/app.conf").should == example_export_file("supervisord/app-alpha-1.conf")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.conf")
    supervisord.export
    supervisord.export
  end

  context "with concurrency" do
    let(:formation) { "alpha=2" }

    it "exports to the filesystem with concurrency" do
      supervisord.export
      File.read("/tmp/init/app.conf").should == example_export_file("supervisord/app-alpha-2.conf")
    end
  end

end
