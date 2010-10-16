require "spec_helper"
require "foreman/engine"

describe "Foreman::Engine" do
  subject { Foreman::Engine.new("Psfile") }

  describe "initialize" do
    describe "without an existing Psfile" do
      it "raises an error" do
        lambda { subject }.should raise_error
      end
    end

    describe "with a Psfile" do
      it "reads the processes" do
        write_psfile
        subject.processes["alpha"].command.should == "./alpha"
        subject.processes["bravo"].command.should == "./bravo"
      end
    end
  end

  describe "start" do
    it "forks the processes" do
      write_psfile
      mock(subject).fork(subject.processes["alpha"], {})
      mock(subject).fork(subject.processes["bravo"], {})
      mock(subject).watch_for_termination
      subject.start
    end

    it "handles concurrency" do
      write_psfile
      mock(subject).fork_individual(subject.processes["alpha"], 5000)
      mock(subject).fork_individual(subject.processes["alpha"], 5001)
      mock(subject).fork_individual(subject.processes["bravo"], 5100)
      mock(subject).watch_for_termination
      subject.start(:concurrency => "alpha=2")
    end
  end

  describe "execute" do
    it "runs the processes" do
      write_psfile
      mock(subject).fork(subject.processes["alpha"], {})
      mock(subject).watch_for_termination
      subject.execute("alpha")
    end
  end
end
