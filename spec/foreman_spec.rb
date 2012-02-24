require "spec_helper"
require "foreman"

describe Foreman do

  describe "VERSION" do
    subject { Foreman::VERSION }
    it { should be_a String }
  end

  describe "runner" do
    it "should exist" do
      File.exists?(Foreman.runner).should == true
    end
  end
end
