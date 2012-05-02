require 'spec_helper'
require 'foreman/procfile'
require 'pathname'
require 'tmpdir'

describe Foreman::Procfile do
  subject { described_class.new }

  let(:testdir) { Pathname(Dir.tmpdir) }
  let(:procfile) { testdir + 'Procfile' }

  it "can have a process appended to it" do
    subject << ['alpha', './alpha']
    subject['alpha'].should be_a(Foreman::ProcfileEntry)
  end

  it "can write itself out to a file" do
    subject << ['alpha', './alpha']
    subject.write(procfile)
    procfile.read.should == "alpha: ./alpha\n"
  end

  it "can re-read entries from a file" do
    procfile.open('w') { |io| io.puts "gamma: ./radiation", "theta: ./rate" }
    subject << ['alpha', './alpha']
    subject.load(procfile)
    subject.process_names.should have(2).members
    subject.process_names.should include('gamma', 'theta')
  end

end
