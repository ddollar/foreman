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
  before(:each) { stub(FakeFS::FileUtils).chmod }

  it "exports to the filesystem" do
    monit.export

    File.read("/tmp/init/app.monitrc").should == example_export_file("monit/app-alpha1-bravo1.monitrc")
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.monitrc")

    monit.export
    monit.export
  end

  context "with concurrency" do
    let(:options) { Hash[:concurrency => "alpha=2"] }

    it "exports to the filesystem with concurrency" do
      monit.export

      File.read("/tmp/init/app.monitrc").should == example_export_file("monit/app-alpha2.monitrc")
    end
  end

  context "with concurrency and process monitoring" do
    let(:options) do {
      :concurrency      => "alpha=2,bravo=1",
      :"restart-on-mem" => "alpha=157 MB,bravo=300 MB", # explicit processes
      :"restart-on-cpu" => "alpha=25%",                 # specific processes
      :"alert-on-cpu"   => "22%"                        # all
    }
    end

    it "exports to the filesystem with concurrency and cpu/mem monitoring" do
      monit.export

      File.read("/tmp/init/app.monitrc").should == example_export_file("monit/app-alpha2-bravo1-monitoring.monitrc")
    end
  end

end
