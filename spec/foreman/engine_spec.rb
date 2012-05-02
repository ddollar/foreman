require "spec_helper"
require "foreman/engine"

describe "Foreman::Engine", :fakefs do
  subject { Foreman::Engine.new("Procfile", {}) }

  before do
    any_instance_of(Foreman::Engine) do |engine|
      stub(engine).proctitle
      stub(engine).termtitle
    end
  end

  describe "initialize" do
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

  describe "directories" do
    it "has the directory default relative to the Procfile" do
      write_procfile "/some/app/Procfile"
      engine = Foreman::Engine.new("/some/app/Procfile")
      engine.directory.should == "/some/app"
    end
  end

  describe "environment" do
    before(:each) do
      write_procfile
      stub(Process).fork
      any_instance_of(Foreman::Engine) do |engine|
        stub(engine).info
        stub(engine).spawn_processes
        stub(engine).watch_for_termination
      end
    end

    it "should read if specified" do
      File.open("/tmp/env", "w") { |f| f.puts("FOO=baz") }
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env")
      engine.environment.should == {"FOO"=>"baz"}
      engine.start
    end

    it "should read more than one if specified" do
      File.open("/tmp/env1", "w") { |f| f.puts("FOO=bar") }
      File.open("/tmp/env2", "w") { |f| f.puts("BAZ=qux") }
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env1,/tmp/env2")
      engine.environment.should == { "FOO"=>"bar", "BAZ"=>"qux" }
      engine.start
    end

    it "should handle quoted values" do
      File.open("/tmp/env", "w") do |f|
        f.puts 'FOO=bar'
        f.puts 'BAZ="qux"'
        f.puts "FRED='barney'"
        f.puts 'OTHER="escaped\"quote"'
      end
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env")
      engine.environment.should == { "FOO" => "bar", "BAZ" => "qux", "FRED" => "barney", "OTHER" => 'escaped"quote' }
    end

    it "should fail if specified and doesnt exist" do
      mock.instance_of(Foreman::Engine).error("No such file: /tmp/env")
      engine = Foreman::Engine.new("Procfile", :env => "/tmp/env")
    end

    it "should read .env if none specified" do
      File.open(".env", "w") { |f| f.puts("FOO=qoo") }
      engine = Foreman::Engine.new("Procfile")
      engine.environment.should == {"FOO"=>"qoo"}
      engine.start
    end

    it "should be loaded relative to the Procfile" do
      FileUtils.mkdir_p "/some/app"
      File.open("/some/app/.env", "w") { |f| f.puts("FOO=qoo") }
      write_procfile "/some/app/Procfile"
      engine = Foreman::Engine.new("/some/app/Procfile")
      engine.environment.should == {"FOO"=>"qoo"}
      engine.start
    end
  end

  describe "utf8" do
    before(:each) do
      File.open("Procfile", "w") do |file|
        file.puts "utf8: #{resource_path("bin/utf8")}"
      end
    end

    it "should spawn" do
      stub(subject).watch_for_output
      stub(subject).watch_for_termination
      subject.start
      Process.waitall
      mock(subject).info(/started with pid \d+/, "utf8.1", anything)
      mock(subject).info("\xff\x03\n", "utf8.1", anything)
      subject.send(:poll_readers)
      subject.send(:poll_readers)
    end
  end
end
