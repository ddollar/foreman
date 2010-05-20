require "spec_helper"
require "foreman/cli"

describe "Foreman::CLI" do
  subject { Foreman::CLI.new }

  describe "start" do
    #let(:engine) { stub_engine }

    describe "with a non-existent Procifile" do
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
    describe "with a non-existent Procifile" do
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
            subject.export("testapp", "Procfile", "invalidformatter")
          end
        end
      end

      describe "with a valid config" do
        before(:each) { write_foreman_config("testapp") }

        it "runs successfully" do
          dont_allow(subject).error
          subject.export("testapp")
        end
      end
    end
  end

  describe "scale" do
    describe "without an existing configuration" do
      # TODO
    end

    describe "with an existing configuration" do
      before(:each) { write_foreman_config("testapp") }

      it "scales the specified process" do
        mock.instance_of(Foreman::Configuration).scale("testprocess", "2")
        subject.scale("testapp", "testprocess", "2")
      end
    end
  end

end
