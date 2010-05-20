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
      it "displays an error" do
        mock_error(subject, "No such app: testapp.") do
          subject.scale("testapp", "alpha", "2")
        end
      end
    end

    describe "with an existing configuration" do
      before(:each) { write_foreman_config("testapp") }

      it "scales a process that exists" do
        mock.instance_of(Foreman::Configuration).scale("alpha", "2")
        subject.scale("testapp", "alpha", "2")
      end

      it "errors if a process that does not exist is specified" do
        mock_error(subject, "No such process: invalidprocess.") do
          dont_allow.instance_of(Foreman::Configuration).scale
          subject.scale("testapp", "invalidprocess", "2")
        end
      end
    end
  end

end
