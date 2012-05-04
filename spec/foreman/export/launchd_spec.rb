require "spec_helper"
require "foreman/engine"
require "foreman/export/launchd"
require "tmpdir"

describe Foreman::Export::Launchd, :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine)   { Foreman::Engine.new(procfile) }
  let(:options)  { Hash.new }
  let(:launchd) { Foreman::Export::Launchd.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("launchd") }
  before(:each) { stub(launchd).say }

  it "exports to the filesystem" do
    launchd.export
    
    normalize_space(File.read("/tmp/init/app-alpha-1.plist")).should == normalize_space(example_export_file("launchd/launchd-a.default"))
    
    normalize_space(File.read("/tmp/init/app-bravo-1.plist")).should == normalize_space(example_export_file("launchd/launchd-b.default"))
    
  end

end
