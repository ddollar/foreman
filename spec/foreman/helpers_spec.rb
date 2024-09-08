require "spec_helper"
require "foreman/helpers"

describe "Foreman::Helpers" do
  subject {
    o = Object.new
    o.extend(Foreman::Helpers)
    o
  }

  before do
    module Foo
      class Bar; end
    end
  end

  after do
    Object.send(:remove_const, :Foo)
  end

  it "classifies words" do
    expect(subject.classify("foo")).to eq("Foo")
    expect(subject.classify("foo-bar")).to eq("FooBar")
  end

  it "constantizes words" do
    expect(subject.constantize("Object")).to eq(Object)
    expect(subject.constantize("Foo::Bar")).to eq(Foo::Bar)
  end
end
