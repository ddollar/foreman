require "spec_helper"
require "foreman/cli"

describe "Foreman::CLI", :fakefs do
  subject { Foreman::CLI.new }
  let(:engine) { subject.send(:engine) }
  let(:entries) { engine.procfile.entries.inject({}) { |h,e| h.update(e.name => e) } }

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

      it "can run a single process" do
        dont_allow(subject).error
        stub(engine).watch_for_output
        stub(engine).watch_for_termination
        mock(entries["alpha"]).spawn(1, is_a(IO), engine.directory, {}, 5000) { [] }
        mock(entries["bravo"]).spawn(0, is_a(IO), engine.directory, {}, 5100) { [] }
        subject.start("alpha")
      end
    end
  end

  describe "export" do
    describe "options" do
      it "uses .foreman" do
        write_procfile
        File.open(".foreman", "w") { |f| f.puts "concurrency: alpha=2" }
        mock_export = mock(Foreman::Export::Upstart)
        mock(Foreman::Export::Upstart).new("/upstart", is_a(Foreman::Engine), { "concurrency" => "alpha=2" }) { mock_export }
        mock_export.export
        foreman %{ export upstart /upstart }
      end

      it "respects --env" do
        write_procfile
        write_env("envfile")
        mock_export = mock(Foreman::Export::Upstart)
        mock(Foreman::Export::Upstart).new("/upstart", is_a(Foreman::Engine), { "env" => "envfile" }) { mock_export }
        mock_export.export
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

      describe "with a formatter with a generic error" do
        before do
          mock(Foreman::Export).formatter("errorful") { Class.new(Foreman::Export::Base) do
            def export
              raise Foreman::Export::Exception.new("foo")
            end
          end }
        end

        it "prints an error" do
          mock_error(subject, "foo") do
            subject.export("errorful")
          end
        end
      end

      describe "with a valid config" do
        before(:each) { write_foreman_config("testapp") }

        it "runs successfully" do
          dont_allow(subject).error
          mock_export = mock(Foreman::Export::Upstart)
          mock(Foreman::Export::Upstart).new("/tmp/foo", is_a(Foreman::Engine), {}) { mock_export }
          mock_export.export
          subject.export("upstart", "/tmp/foo")
        end
      end
    end
  end

  describe "check" do
    describe "with a valid Procfile" do
      before { write_procfile }

      it "displays the jobs" do
        mock(subject).puts("valid procfile detected (alpha, bravo)")
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

    describe "without a Procfile" do
      it "displays an error" do
        mock_error(subject, "Procfile does not exist.") do
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
