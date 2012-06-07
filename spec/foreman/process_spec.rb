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
  let(:name)    { "testproc" }
  let(:entry)   { OpenStruct.new :name => name, :command => command }

  its(:entry) { entry }
  its(:num)   { number }
  its(:port)  { port }
  its(:name)  { "#{name}.#{port}" }
  its(:pid)   { nil }

  describe '#run' do
    let(:pipe)       { :pipe }
    let(:basedir)    { Dir.mktmpdir }
    let(:env)        {{ 'foo' => 'xyzzy' }}
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
          ENV['foo'].should == 'xyzzy'
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

      # Sanity check to ensure subsequent tests make sense.
      it 'should not echo command line in output' do
        run %q{ true xyzzy }
        output.should_not include('xyzzy')
      end

      it 'should capture stdout' do
        run %q{ echo xyzzy }
        output.should include('xyzzy')
      end

      # There used to be a hack for this but now simply it falls out
      # of the fact that all commands are passed through the shell.
      it 'should substitute environment variables' do
        run %q{ echo $foo }
        output.should include('xyzzy')
      end

      it 'should handle shell commands' do
        run %q{ echo xyzzy | tr x-z a-c }
        output.should include('abccb')
      end

      it 'should capture stderr' do
        run %q{ echo xyzzy >&2 }
        output.should include('xyzzy')
      end

      it 'should handle multi-word arguments' do
        run %{ sh -c 'echo xyzzy | tr x-z a-c' }
        output.should include('abccb')
      end

      # This used to fail because Foreman had a special hack for
      # parsing out things that looked like environment variables.
      it 'should not clobber "$foo"-subexpressions' do
        run %q{ echo '$xyzzy' }
        output.should include('$xyzzy')
      end
    end
  end
end
