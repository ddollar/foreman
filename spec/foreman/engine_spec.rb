require "spec_helper"
require "foreman/engine"

describe "Foreman::Engine" do
  subject { Foreman::Engine.new("Procfile") }

  describe "initialize" do
    describe "without an existing Procfile" do
      it "raises an error" do
        lambda { subject }.should raise_error
      end
    end
    
    describe "with a Procfile" do
      it "reads the processes" do
        write_procfile
        subject.processes["alpha"].command.should == "./alpha"
        subject.processes["bravo"].command.should == "./bravo"
      end
    end
  end
  
  describe "start" do
    it "forks the processes" do
      write_procfile
      mock(subject).fork(subject.processes["alpha"])
      mock(subject).fork(subject.processes["bravo"])
      mock(subject).run_loop
      subject.start
    end
  end

  describe "execute" do
    it "runs the processes" do
      write_procfile
      mock(subject).run(subject.processes["alpha"], false)
      subject.execute("alpha")
    end
  end
end
