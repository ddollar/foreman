require "spec_helper"
require "foreman/engine"
require "foreman/export/inittab"
require "tmpdir"

describe Foreman::Export::Inittab do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:inittab)  { Foreman::Export::Inittab.new(engine, "/tmp/init", :concurrency => "alpha=2") }

  before(:each) { load_export_templates_into_fakefs("inittab") }
  before(:each) { stub(inittab).say }

  it "exports to the filesystem" do
    inittab.export
    File.read("/tmp/init/app").should == example_export_file("inittab/app.inittab")
  end
  
  context "exporting a single process" do    
    it "exports to the file system" do
      inittab.export("alpha")
      File.read("/tmp/init/app").should == example_export_file("inittab/process.inittab")
    end
  end
end