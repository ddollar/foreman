require "spec_helper"
require "foreman/engine"
require "foreman/export/runit"
require "tmpdir"

describe Foreman::Export::Runit, :fakefs do
  let(:procfile) { FileUtils.mkdir_p("/tmp/app"); write_procfile("/tmp/app/Procfile", 'bar=baz') }
  let(:engine) { Foreman::Engine.new(procfile) }
  let(:runit) { Foreman::Export::Runit.new(engine) }

  before(:each) { load_export_templates_into_fakefs("runit") }
  before(:each) { stub(runit).say }
  before(:each) { stub(FakeFS::FileUtils).chmod }

  it "exports to the filesystem" do
    FileUtils.mkdir_p('/tmp/init')
    runit.export('/tmp/init', :concurrency => "alpha=2,bravo=1")

    File.read("/tmp/init/app-alpha-1/run").should == example_export_file('runit/app-alpha-1-run')
    File.read("/tmp/init/app-alpha-1/log/run").should ==
        example_export_file('runit/app-alpha-1-log-run')
    File.read("/tmp/init/app-alpha-1/env/PORT").should == "5000\n"
    File.read("/tmp/init/app-alpha-1/env/BAR").should == "baz\n"

    File.read("/tmp/init/app-alpha-2/run").should == example_export_file('runit/app-alpha-2-run')
    File.read("/tmp/init/app-alpha-2/log/run").should ==
        example_export_file('runit/app-alpha-2-log-run')
    File.read("/tmp/init/app-alpha-2/env/PORT").should == "5001\n"
    File.read("/tmp/init/app-alpha-2/env/BAR").should == "baz\n"

    File.read("/tmp/init/app-bravo-1/run").should == example_export_file('runit/app-bravo-1-run')
    File.read("/tmp/init/app-bravo-1/log/run").should ==
        example_export_file('runit/app-bravo-1-log-run')
    File.read("/tmp/init/app-bravo-1/env/PORT").should == "5100\n"
  end
end
