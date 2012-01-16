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
    normalize_space(File.read("/tmp/init/app.pill")).should == normalize_space(example_export_file("bluepill/app.pill"))
  end

  it "exports to the filesystem with concurrency" do
    bluepill.export("/tmp/init", :concurrency => "alpha=2")
    
    normalize_space(File.read("/tmp/init/app.pill")).should == normalize_space(example_export_file("bluepill/app-concurrency.pill"))
  end
end