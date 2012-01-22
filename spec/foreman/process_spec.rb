require "spec_helper"
require "foreman/process"
require 'ostruct'

describe Foreman::Process do
  subject { described_class.new entry, number, port }

  let(:number)  { 1 }
  let(:port)    { 777 }
  let(:command) { :script }
  let(:name)    { :foobar }
  let(:entry)   { OpenStruct.new :name => name, :command => command }

  its(:entry) { entry }
  its(:num)   { number }
  its(:port)  { port }
  its(:name)  { "#{name}.#{port}" }
  its(:pid)   { nil }
end
