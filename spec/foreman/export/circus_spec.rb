require "spec_helper"
require "foreman/engine"
require "foreman/export/circus"
require "tmpdir"

describe Foreman::Export::Circus, :fakefs do
  let(:procfile)    { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:formation)   { nil }
  let(:engine)      { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)     { Hash.new }
  let(:circus) { Foreman::Export::Circus.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("circus") }
  before(:each) { stub(circus).say }

  it "exports to the filesystem" do
    circus.export
    File.read("/tmp/init/app.ini").should == example_export_file("circus/app-alpha-1.ini")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.ini")
    circus.export
    circus.export
  end

  context "with concurrency" do
    let(:formation) { "alpha=2" }

    it "exports to the filesystem with concurrency" do
      circus.export
      File.read("/tmp/init/app.ini").should == example_export_file("circus/app-alpha-2.ini")
    end
  end

end
