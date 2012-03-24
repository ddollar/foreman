require "spec_helper"
require "foreman/engine"
require "foreman/export/monit"
require "tmpdir"

describe Foreman::Export::Monit, :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:options)  { Hash.new }
  let(:monit)    { Foreman::Export::Monit.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("monit") }
  before(:each) { stub(monit).say }

  it "exports to the filesystem" do
    monit.export

    File.read("/tmp/init/app.monitrc").should         == example_export_file("monit/app.monitrc")
    # File.read("/tmp/init/app-alpha.conf").should   == example_export_file("monit/app-alpha.conf")
    # File.read("/tmp/init/app-alpha-1.conf").should == example_export_file("monit/app-alpha-1.conf")
    # File.read("/tmp/init/app-bravo.conf").should   == example_export_file("monit/app-bravo.conf")
    # File.read("/tmp/init/app-bravo-1.conf").should == example_export_file("monit/app-bravo-1.conf")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.monitrc")
    # mock(FileUtils).rm("/tmp/init/app-alpha.conf")
    # mock(FileUtils).rm("/tmp/init/app-alpha-1.conf")
    # mock(FileUtils).rm("/tmp/init/app-bravo.conf")
    # mock(FileUtils).rm("/tmp/init/app-bravo-1.conf")

    monit.export
    monit.export
  end

  context "with concurrency" do
    let(:options) { Hash[:concurrency => "alpha=2"] }

    it "exports to the filesystem with concurrency" do
      monit.export

      File.read("/tmp/init/app.monitrc").should         == example_export_file("monit/app.monitrc")
      # File.read("/tmp/init/app-alpha.conf").should      == example_export_file("monit/app-alpha.conf")
      # File.read("/tmp/init/app-alpha-1.conf").should    == example_export_file("monit/app-alpha-1.conf")
      # File.read("/tmp/init/app-alpha-2.conf").should    == example_export_file("monit/app-alpha-2.conf")
      # File.exists?("/tmp/init/app-bravo-1.conf").should == false
    end
  end

end
