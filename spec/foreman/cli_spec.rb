require "spec_helper"
require "foreman/cli"

describe "Foreman::CLI" do
  subject { Foreman::CLI.new }

  describe "start" do
    describe "with a non-existent Procfile" do
      it "prints an error" do
        mock_error(subject, "Procfile does not exist.") do
          dont_allow.instance_of(Foreman::Engine).start
          subject.start
        end
      end
    end

    describe "with a Procfile" do
      before(:each) { write_procfile }

      it "runs successfully" do
        dont_allow(subject).error
        mock.instance_of(Foreman::Engine).start
        subject.start
      end
    end
  end

  describe "export" do
    describe "options" do
      it "respects --env" do
        write_procfile
        write_env("envfile")
        mock.instance_of(Foreman::Export::Upstart).export("/upstart", { "env" => "envfile" })
        foreman %{ export upstart /upstart --env envfile }
      end
    end

    describe "with a non-existent Procfile" do
      it "prints an error" do
        mock_error(subject, "Procfile does not exist.") do
          dont_allow.instance_of(Foreman::Engine).export
          subject.export("testapp")
        end
      end
    end

    describe "with a Procfile" do
      before(:each) { write_procfile }

      describe "with an invalid formatter" do
        it "prints an error" do
          mock_error(subject, "Unknown export format: invalidformatter.") do
            subject.export("invalidformatter")
          end
        end
      end

      describe "with a valid config" do
        before(:each) { write_foreman_config("testapp") }

        it "runs successfully" do
          dont_allow(subject).error
          mock.instance_of(Foreman::Export::Upstart).export("/tmp/foo", {})
          subject.export("upstart", "/tmp/foo")
        end
      end
    end
  end

  describe "check" do
    describe "with a valid Procfile" do
      before { write_procfile }

      it "displays the jobs" do
        mock(subject).display("valid procfile detected (alpha, bravo)")
        subject.check
      end
    end

    describe "with a blank Procfile" do
      before do
        FileUtils.touch("Procfile")
      end

      it "displays an error" do
        mock_error(subject, "no processes defined") do
          subject.check
        end
      end
    end
  end
  
  describe "run" do
    describe "with a valid Procfile" do
      before { write_procfile }

      describe "and a command" do
        let(:command) { ["ls", "-l"] }
        
        before(:each) do
          stub(subject).exec
        end
        
        it "should load the environment file" do
          write_env
          preserving_env do
            subject.run *command
            ENV["FOO"].should == "bar"
          end
          
          ENV["FOO"].should be_nil
        end
        
        it "should runute the command as a string" do
          mock(subject).exec(command.join(" "))
          subject.run *command
        end
      end
      
      describe "and a non-existent command" do
        let(:command) { "iuhtngrglhulhdfg" }
        
        it "should print an error" do
          mock_error(subject, "command not found: #{command}") do
            subject.run command
          end
        end
      end
      
      describe "and a non-executable command" do
        let(:command) { __FILE__ }
        
        it "should print an error" do
          mock_error(subject, "not executable: #{command}") do
            subject.run command
          end
        end
      end
    end
  end

end
