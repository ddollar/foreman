require 'spec_helper'
require 'foreman/process'
require 'ostruct'
require 'timeout'
require 'tmpdir'

describe Foreman::Process do
  subject { described_class.new entry, number, port }

  let(:number)  { 1 }
  let(:port)    { 777 }
  let(:command) { "script" }
  let(:name)    { "foobar" }
  let(:entry)   { OpenStruct.new :name => name, :command => command }

  its(:entry) { entry }
  its(:num)   { number }
  its(:port)  { port }
  its(:name)  { "#{name}.#{port}" }
  its(:pid)   { nil }

  describe '#run' do
    let(:pipe)       { :pipe }
    let(:basedir)    { Dir.mktmpdir }
    let(:env)        {{ 'foo' => 'bar' }}
    let(:init_delta) { 0.1 }

    after { FileUtils.remove_entry_secure basedir }

    def run(cmd=command)
      entry.command = cmd
      subject.run pipe, basedir, env
      subject.detach && sleep(init_delta)
    end

    def run_file(executable, code)
      file = File.open("#{basedir}/script", 'w') {|it| it << code }
      run "#{executable} #{file.path}"
      sleep 1
    end

    context 'options' do
      it 'should set PORT for environment' do
        mock(subject).run_process(basedir, command, pipe) do
          ENV['PORT'].should == port.to_s
        end
        run
      end

      it 'should set custom variables for environment' do
        mock(subject).run_process(basedir, command, pipe) do
          ENV['foo'].should == 'bar'
        end
        run
      end

      it 'should restore environment afterwards' do
        mock(subject).run_process(basedir, command, pipe)
        run
        ENV.should_not include('PORT', 'foo')
      end
    end

    context 'process' do
      around do |spec|
        IO.pipe do |reader, writer|
          @reader, @writer = reader, writer
          spec.run
        end
      end

      let(:pipe) { @writer }
      let(:output) { @reader.read_nonblock 1024 }

      it 'should not block' do
        expect {
          Timeout.timeout(2*init_delta) { run 'sleep 2' }
        }.should_not raise_exception
      end

      it 'should be alive' do
        run 'sleep 1'
        subject.should be_alive
      end

      it 'should be dead' do
        run 'exit'
        subject.should be_dead
      end

      it 'should be killable' do
        run 'sleep 1'
        subject.kill 'TERM'
        subject.should be_dead
      end

      it 'should send different signals' do
        run_file 'ruby', <<-CODE
          trap "TERM", "IGNORE"
          loop { sleep 1 }
        CODE
        subject.should be_alive
        subject.kill 'TERM'
        subject.should be_alive
        subject.kill 'KILL'
        subject.should be_dead
      end

      it 'should redirect stdout' do
        run 'echo hey'
        output.should include('hey')
      end

      it 'should redirect stderr' do
        run 'echo hey >2'
        output.should include('hey')
      end

      it 'should handle variables' do
        run 'echo $PORT'
        output.should include('777')
      end

      it 'should handle arguments' do
        pending
        run %{ sh -c "trap '' TERM; sleep 10" }
        subject.should be_alive
      end
    end
  end
end
