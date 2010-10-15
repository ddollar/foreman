require "spec_helper"
require "foreman/engine"

describe "Foreman::Engine" do
  subject { Foreman::Engine.new("Pstypes") }

  describe "initialize" do
    describe "without an existing Pstypes" do
      it "raises an error" do
        lambda { subject }.should raise_error
      end
    end

    describe "with a Pstypes" do
      it "reads the processes" do
        write_pstypes
        subject.processes["alpha"].command.should == "./alpha"
        subject.processes["bravo"].command.should == "./bravo"
      end
    end
  end

  describe "start" do
    it "forks the processes" do
      write_pstypes
      mock(subject).fork(subject.processes["alpha"], {})
      mock(subject).fork(subject.processes["bravo"], {})
      mock(subject).watch_for_termination
      subject.start
    end

    it "handles concurrency" do
      write_pstypes
      mock(subject).fork_individual(subject.processes["alpha"], 5000)
      mock(subject).fork_individual(subject.processes["alpha"], 5001)
      mock(subject).fork_individual(subject.processes["bravo"], 5100)
      mock(subject).watch_for_termination
      subject.start(:concurrency => "alpha=2")
    end
  end

  describe "execute" do
    it "runs the processes" do
      write_pstypes
      mock(subject).fork(subject.processes["alpha"], {})
      mock(subject).watch_for_termination
      subject.execute("alpha")
    end
  end
end
