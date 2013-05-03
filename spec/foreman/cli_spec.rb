require "spec_helper"
require "foreman/cli"

describe "Foreman::CLI", :fakefs do
  subject { Foreman::CLI.new }

  describe ".foreman" do
    before { File.open(".foreman", "w") { |f| f.puts "formation: alpha=2" } }

    it "provides default options" do
      subject.send(:options)["formation"].should == "alpha=2"
    end

    it "is overridden by options at the cli" do
      subject = Foreman::CLI.new([], :formation => "alpha=3")
      subject.send(:options)["formation"].should == "alpha=3"
    end
  end

  describe "start" do
    describe "when a Procfile doesnt exist", :fakefs do
      it "displays an error" do
        mock_error(subject, "Procfile does not exist.") do
          dont_allow.instance_of(Foreman::Engine).start
          subject.start
        end
      end
    end

    describe "with a valid Procfile" do
      it "can run a single command" do
        without_fakefs do
          output = foreman("start env -f #{resource_path("Procfile")}")
          output.should     =~ /env.1/
          output.should_not =~ /test.1/
        end
      end

      it "can run all commands" do
        without_fakefs do
          output = foreman("start -f #{resource_path("Procfile")} -e #{resource_path(".env")}")
          output.should =~ /echo.1 \| echoing/
          output.should =~ /env.1  \| bar/
          output.should =~ /test.1 \| testing/
        end
      end

      it "sets PS variable with the process name" do
        without_fakefs do
          output = foreman("start -f #{resource_path("Procfile")}")
          output.should =~ /ps.1   \| PS env var is ps.1/
        end
      end
    end
  end

  describe "check" do
    it "with a valid Procfile displays the jobs" do
      write_procfile
      foreman("check").should == "valid procfile detected (alpha, bravo, foo_bar, foo-bar)\n"
    end

    it "with a blank Procfile displays an error" do
      FileUtils.touch "Procfile"
      foreman("check").should == "ERROR: no processes defined\n"
    end

    it "without a Procfile displays an error" do
      FileUtils.rm_f "Procfile"
      foreman("check").should == "ERROR: Procfile does not exist.\n"
    end
  end

  describe "run" do
    it "can run a command" do
      forked_foreman("run echo 1").should == "1\n"
    end

    it "includes the environment" do
      forked_foreman("run #{resource_path("bin/env FOO")} -e #{resource_path(".env")}").should == "bar\n"
    end

    it "can run a command from the Procfile" do
      forked_foreman("run -f #{resource_path("Procfile")} test").should == "testing\n"
    end

    it "exits with the same exit code as the command" do
      fork_and_get_exitstatus("run echo 1").should == 0
      fork_and_get_exitstatus("run date 'invalid_date'").should == 1
    end
  end

  describe "version" do
    it "displays gem version" do
      foreman("version").chomp.should == Foreman::VERSION
    end

    it "displays gem version on shortcut command" do
      foreman("-v").chomp.should == Foreman::VERSION
    end
  end

  describe "when posix-spawn is not present on ruby 1.8" do
    it "should fail with an error" do
      mock(Kernel).require('posix/spawn') { raise LoadError }
      output = foreman("start -f #{resource_path("Procfile")}")
      output.should == "ERROR: foreman requires gem `posix-spawn` on Ruby #{RUBY_VERSION}. Please `gem install posix-spawn`.\n"
    end
  end if running_ruby_18?

end
