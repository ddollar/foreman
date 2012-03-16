require "spec_helper"
require "foreman/color"

describe Foreman::Color do

  let(:io) { Object.new }

  it "should extend an object with colorization" do
    Foreman::Color.enable(io)
    io.should respond_to(:color)
  end

  it "should not colorize if the object does not respond to isatty" do
    mock(io).respond_to?(:isatty) { false }
    Foreman::Color.enable(io)
    io.color(:white).should == ""
  end

  it "should not colorize if the object is not a tty" do
    mock(io).isatty { false }
    Foreman::Color.enable(io)
    io.color(:white).should == ""
  end

  it "should colorize if the object is a tty" do
    mock(io).isatty { true }
    Foreman::Color.enable(io)
    io.color(:white).should == "\e[37m"
  end

end
