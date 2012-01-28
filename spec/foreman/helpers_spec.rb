require "spec_helper"
require "foreman/helpers"

describe "Foreman::Helpers" do
  before do
    module Foo
      class Bar; end
    end
  end

  after do
    Object.send(:remove_const, :Foo)
  end

  subject { o = Object.new; o.extend(Foreman::Helpers); o }

  it "should classify words" do
    subject.classify("foo").should == "Foo"
    subject.classify("foo-bar").should == "FooBar"
  end

  it "should constantize words" do
    subject.constantize("Object").should == Object
    subject.constantize("Foo::Bar").should == Foo::Bar
  end
end
