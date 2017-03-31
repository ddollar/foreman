require "spec_helper"
require "foreman/engine"
require "foreman/export/yaml"
require "tmpdir"

describe Foreman::Export::Yaml, :fakefs do
  let(:procfile)  { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile") }
  let(:formation) { nil }
  let(:engine)    { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)   { Hash.new }
  let(:yaml)      { Foreman::Export::Yaml.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("yaml") }
  before(:each) { stub(yaml).say }

  it "exports to the filesystem" do
    yaml.export
    normalize_space(File.read("/tmp/init/app.yml")).should == normalize_space(example_export_file("yaml/app.yml"))
  end

  it "cleans up if exporting into an existing dir" do
    mock(FileUtils).rm("/tmp/init/app.yml")

    yaml.export
    yaml.export
  end

  context "with a process formation" do
    let(:formation) { "alpha=2" }

    it "exports to the filesystem with concurrency" do
      yaml.export
      normalize_space(File.read("/tmp/init/app.yml")).should == normalize_space(example_export_file("yaml/app-concurrency.yml"))
    end
  end

end
