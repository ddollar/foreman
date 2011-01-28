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
        mock.instance_of(Foreman::Engine).start({})
        subject.start
      end
    end
  end

  describe "export" do
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

end
