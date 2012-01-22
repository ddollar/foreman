require "spec_helper"

describe "spec helpers" do
  describe "#preserving_env" do
    after { ENV.delete "FOO" }

    it "should remove added environment vars" do
      preserving_env { ENV["FOO"] = "baz" }
      ENV["FOO"].should == nil
    end

    it "should reset modified environment vars" do
      ENV["FOO"] = "bar"
      preserving_env { ENV["FOO"] = "baz"}
      ENV["FOO"].should == "bar"
    end
  end
end
