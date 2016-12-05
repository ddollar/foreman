require "spec_helper"
require "foreman/engine"
require "foreman/export/systemd"
require "tmpdir"

describe Foreman::Export::Systemd, :fakefs do
  let(:procfile)  { write_procfile("/tmp/app/Procfile") }
  let(:formation) { nil }
  let(:engine)    { Foreman::Engine.new(:formation => formation).load_procfile(procfile) }
  let(:options)   { Hash.new }
  let(:systemd)   { Foreman::Export::Systemd.new("/tmp/init", engine, options) }

  before(:each) { load_export_templates_into_fakefs("systemd") }
  before(:each) { allow(systemd).to receive(:say) }

  it "exports to the filesystem" do
    systemd.export

    expect(File.read("/tmp/init/app.target")).to          eq(example_export_file("systemd/app.target"))
    expect(File.read("/tmp/init/app-alpha.target")).to    eq(example_export_file("systemd/app-alpha.target"))
    expect(File.read("/tmp/init/app-alpha@.service")).to  eq(example_export_file("systemd/app-alpha@.service"))
    expect(File.read("/tmp/init/app-bravo.target")).to    eq(example_export_file("systemd/app-bravo.target"))
    expect(File.read("/tmp/init/app-bravo@.service")).to  eq(example_export_file("systemd/app-bravo@.service"))

    expect(File.directory?("/tmp/init/app-alpha.target.wants")).to                      be_truthy
    expect(File.symlink?("/tmp/init/app-alpha.target.wants/app-alpha@5000.service")).to be_truthy
  end

  it "cleans up if exporting into an existing dir" do
    expect(FileUtils).to receive(:rm).with("/tmp/init/app.target")

    expect(FileUtils).to receive(:rm).with("/tmp/init/app-alpha@.service")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-alpha.target")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-alpha.target.wants/app-alpha@5000.service")
    expect(FileUtils).to receive(:rm_r).with("/tmp/init/app-alpha.target.wants")

    expect(FileUtils).to receive(:rm).with("/tmp/init/app-bravo.target")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-bravo@.service")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-bravo.target.wants/app-bravo@5100.service")
    expect(FileUtils).to receive(:rm_r).with("/tmp/init/app-bravo.target.wants")

    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo_bar.target")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo_bar@.service")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo_bar.target.wants/app-foo_bar@5200.service")
    expect(FileUtils).to receive(:rm_r).with("/tmp/init/app-foo_bar.target.wants")

    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo-bar.target")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo-bar@.service")
    expect(FileUtils).to receive(:rm).with("/tmp/init/app-foo-bar.target.wants/app-foo-bar@5300.service")
    expect(FileUtils).to receive(:rm_r).with("/tmp/init/app-foo-bar.target.wants")


    systemd.export
    systemd.export
  end

  it "includes environment variables" do
    engine.env['KEY'] = 'some "value"'
    systemd.export
    expect(File.read("/tmp/init/app-alpha@.service")).to match(/KEY=some "value"/)
  end

  context "with a formation" do
    let(:formation) { "alpha=2" }

    it "exports to the filesystem with concurrency" do
      systemd.export

      expect(File.read("/tmp/init/app.target")).to             eq(example_export_file("systemd/app.target"))
      expect(File.read("/tmp/init/app-alpha.target")).to       eq(example_export_file("systemd/app-alpha.target"))
      expect(File.read("/tmp/init/app-alpha@.service")).to     eq(example_export_file("systemd/app-alpha@.service"))
      expect(File.read("/tmp/init/app-bravo.target")).to       eq(example_export_file("systemd/app-bravo.target"))
      expect(File.read("/tmp/init/app-bravo@.service")).to     eq(example_export_file("systemd/app-bravo@.service"))
    end
  end

  context "with alternate templates" do
    let(:template) { "/tmp/alternate" }
    let(:options)  { { :app => "app", :template => template } }

    before do
      FileUtils.mkdir_p template
      File.open("#{template}/master.target.erb", "w") { |f| f.puts "alternate_template" }
    end

    it "can export with alternate template files" do
      systemd.export
      expect(File.read("/tmp/init/app.target")).to eq("alternate_template\n")
    end
  end

  context "with alternate templates from home dir" do

    before do
      FileUtils.mkdir_p File.expand_path("~/.foreman/templates/systemd")
      File.open(File.expand_path("~/.foreman/templates/systemd/master.target.erb"), "w") do |file|
        file.puts "default_alternate_template"
      end
    end

    it "can export with alternate template files" do
      systemd.export
      expect(File.read("/tmp/init/app.target")).to eq("default_alternate_template\n")
    end
  end

end
