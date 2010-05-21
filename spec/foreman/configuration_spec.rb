require "spec_helper"
require "foreman/configuration"

describe "Foreman::Configuration" do
  subject { Foreman::Configuration.new("testapp") }

  describe "initialize" do
    describe "without an existing config" do
      it "has no processes" do
        subject.processes.length.should == 0
      end
    end

    describe "with an existing config" do
      it "has processes" do
        write_foreman_config("testapp")
        subject.processes["alpha"].should == 1
        subject.processes["bravo"].should == 2
      end
    end
  end

  describe "scale" do
    before(:each) { write_foreman_config("testapp") }

    it "can scale up" do
      mock(subject).system("start testapp-alpha NUM=2")
      mock(subject).system("start testapp-alpha NUM=3")
      subject.scale("alpha", 3)
    end

    it "can scale down" do
      mock(subject).system("stop testapp-bravo NUM=2")
      subject.scale("bravo", 1)
    end
  end
  
  describe "wite" do
    it "can write a configuration file" do
      subject.scale("charlie", 3)
      subject.scale("delta", 4)
      File.read("/etc/foreman/testapp.conf").should == <<-FOREMAN_CONFIG
testapp_processes="charlie delta"
testapp_charlie="3"
testapp_delta="4"
      FOREMAN_CONFIG
    end
  end
end
