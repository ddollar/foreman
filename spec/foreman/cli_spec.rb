require "spec_helper"
require "foreman/cli"

describe "Foreman::CLI" do
  subject { Foreman::CLI.new }

  describe "start" do
    describe "with a non-existent Pstypes" do
      it "prints an error" do
        mock_error(subject, "Pstypes does not exist.") do
          dont_allow.instance_of(Foreman::Engine).start
          subject.start
        end
      end
    end

    describe "with a Pstypes" do
      before(:each) { write_pstypes }

      it "runs successfully" do
        dont_allow(subject).error
        mock.instance_of(Foreman::Engine).start({})
        subject.start
      end
    end
  end

  describe "export" do
    describe "with a non-existent Pstypes" do
      it "prints an error" do
        mock_error(subject, "Pstypes does not exist.") do
          dont_allow.instance_of(Foreman::Engine).export
          subject.export("testapp")
        end
      end
    end

    describe "with a Pstypes" do
      before(:each) { write_pstypes }

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

end
