require "spec_helper"
require "foreman/engine"
require "foreman/export/bluepill"
require "tmpdir"

describe Foreman::Export::Bluepill do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:engine) { Foreman::Engine.new(procfile) }
  let(:bluepill) { Foreman::Export::Bluepill.new(engine) }

  before(:each) { load_export_templates_into_fakefs("bluepill") }
  before(:each) { stub(bluepill).say }

  it "exports to the filesystem" do
    bluepill.export("/tmp/init")
    
    File.read("/tmp/init/app.pill").should == example_export_file("bluepill/app.pill")
  end

end