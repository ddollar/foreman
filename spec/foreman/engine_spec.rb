require "spec_helper"
require "foreman/engine"

class Foreman::Engine::Tester < Foreman::Engine
  attr_reader :buffer

  def startup
    @buffer = ""
  end

  def output(name, data)
    @buffer += "#{name}: #{data}"
  end

  def shutdown
  end
end

describe "Foreman::Engine", :fakefs do
  subject do
    write_procfile "Procfile"
    Foreman::Engine::Tester.new.load_procfile("Procfile")
  end

  describe "initialize" do
    describe "with a Procfile" do
      before { write_procfile }

      it "reads the processes" do
        subject.process("alpha").command.should == "./alpha"
        subject.process("bravo").command.should == "./bravo"
      end
    end
  end

  describe "start" do
    it "forks the processes" do
      mock(subject.process("alpha")).run(anything)
      mock(subject.process("bravo")).run(anything)
      mock(subject).watch_for_output
      mock(subject).watch_for_termination
      subject.start
    end

    it "handles concurrency" do
      subject.options[:formation] = "alpha=2"
      mock(subject.process("alpha")).run(anything).twice
      mock(subject.process("bravo")).run(anything).never
      mock(subject).watch_for_output
      mock(subject).watch_for_termination
      subject.start
    end
  end

  describe "directories" do
    it "has the directory default relative to the Procfile" do
      write_procfile "/some/app/Procfile"
      engine = Foreman::Engine.new.load_procfile("/some/app/Procfile")
      engine.root.should == "/some/app"
    end
  end

  describe "environment" do
    it "should read env files" do
      File.open("/tmp/env", "w") { |f| f.puts("FOO=baz") }
      subject.load_env("/tmp/env")
      subject.env["FOO"].should == "baz"
    end

    it "should read more than one if specified" do
      File.open("/tmp/env1", "w") { |f| f.puts("FOO=bar") }
      File.open("/tmp/env2", "w") { |f| f.puts("BAZ=qux") }
      subject.load_env "/tmp/env1"
      subject.load_env "/tmp/env2"
      subject.env["FOO"].should == "bar"
      subject.env["BAZ"].should == "qux"
    end

    it "should handle quoted values" do
      File.open("/tmp/env", "w") do |f|
        f.puts 'FOO=bar'
        f.puts 'BAZ="qux"'
        f.puts "FRED='barney'"
        f.puts 'OTHER="escaped\"quote"'
      end
      subject.load_env "/tmp/env"
      subject.env["FOO"].should   == "bar"
      subject.env["BAZ"].should   == "qux"
      subject.env["FRED"].should  == "barney"
      subject.env["OTHER"].should == 'escaped"quote'
    end

    it "should handle multiline strings" do
      File.open("/tmp/env", "w") do |f|
        f.puts 'FOO="bar\nbaz"'
      end
      subject.load_env "/tmp/env"
      subject.env["FOO"].should == "bar\nbaz"
    end

    it "should fail if specified and doesnt exist" do
      lambda { subject.load_env "/tmp/env" }.should raise_error(Errno::ENOENT)
    end

    it "should set port from .env if specified" do
      File.open("/tmp/env", "w") { |f| f.puts("PORT=9000") }
      subject.load_env "/tmp/env"
      subject.send(:base_port).should == 9000
    end
  end

end
