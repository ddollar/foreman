require "spec_helper"
require "foreman/engine"

describe "Foreman::Engine", :fakefs do
  subject { Foreman::Engine.new("Procfile", {}) }

  describe "initialize" do
    describe "without an existing Procfile" do
      it "raises an error" do
        lambda { subject }.should raise_error
      end
    end

    describe "with a Procfile" do
      before { write_procfile }

      it "reads the processes" do
        subject.procfile["alpha"].command.should == "./alpha"
        subject.procfile["bravo"].command.should == "./bravo"
      end
    end
  end

  describe "start" do
    it "forks the processes" do
      write_procfile
      mock.instance_of(Foreman::Process).run_process(Dir.pwd, "./alpha", is_a(IO))
      mock.instance_of(Foreman::Process).run_process(Dir.pwd, "./bravo", is_a(IO))
      mock(subject).watch_for_output
      mock(subject).watch_for_termination
      subject.start
    end

    it "handles concurrency" do
      write_procfile
      engine = Foreman::Engine.new("Procfile",:concurrency => "alpha=2")
      mock.instance_of(Foreman::Process).run_process(Dir.pwd, "./alpha", is_a(IO)).twice
      mock.instance_of(Foreman::Process).run_process(Dir.pwd, "./bravo", is_a(IO)).never
      mock(engine).watch_for_output
      mock(engine).watch_for_termination
      engine.start
    end
  end

  describe "environment" do
    before(:each) do
      write_procfile
      stub(Process).fork
    end

    it "should read if specified" do
      File.open("/tmp/env", "w") { |f| f.puts("FOO=baz") }
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env")
      stub(engine).info
      mock(engine).spawn_processes
      mock(engine).watch_for_termination
      engine.environment.should == {"FOO"=>"baz"}
      engine.start
    end

    it "should read more than one if specified" do
      File.open("/tmp/env1", "w") { |f| f.puts("FOO=bar") }
      File.open("/tmp/env2", "w") { |f| f.puts("BAZ=qux") }
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env1,/tmp/env2")
      stub(engine).info
      mock(engine).spawn_processes
      mock(engine).watch_for_termination
      engine.environment.should == { "FOO"=>"bar", "BAZ"=>"qux" }
      engine.start
    end

    it "should fail if specified and doesnt exist" do
      mock.instance_of(Foreman::Engine).error("No such file: /tmp/env")
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env")
    end

    it "should read .env if none specified" do
      File.open(".env", "w") { |f| f.puts("FOO=qoo") }
      engine = Foreman::Engine.new("Procfile")
      mock(engine).spawn_processes
      mock(engine).watch_for_termination
      engine.environment.should == {"FOO"=>"qoo"}
      engine.start
    end
  end
end
