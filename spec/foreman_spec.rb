require "spec_helper"
require "foreman"

describe Foreman do

  describe "VERSION" do
    subject { Foreman::VERSION }
    it { should be_a String }
  end

  describe "::load!(env_file)" do
    before do
      File.open("/tmp/env1", "w") { |f| f.puts("FOO=bar") }
    end

    after do
      ENV['FOO'] = nil
    end

    it "should load env_file into ENV" do
      Foreman.load!("/tmp/env1")
      ENV['FOO'].should == 'bar'
    end 
  end
end
