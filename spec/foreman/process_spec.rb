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

  describe '#run' do
    let(:pipe)    { :pipe }
    let(:basedir) { Dir.mktmpdir }
    let(:env)     {{ 'foo' => 'bar' }}

    let(:run) do
      subject.run pipe, basedir, env
    end

    it 'should change to basedir' do
      mock(Dir).chdir basedir
      run
    end

    it 'should set PORT for environment' do
      mock(subject).run_process(command, pipe) do
        ENV['PORT'].should == port.to_s
      end
      run
    end

    it 'should set custom variables for environment' do
      mock(subject).run_process(command, pipe) do
        ENV['foo'].should == 'bar'
      end
      run
    end

    it 'should restore environment afterwards' do
      mock(subject).run_process command, pipe
      run
      ENV.should_not include('PORT', 'foo')
    end
  end
end
