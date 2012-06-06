require "foreman"
require "rubygems"

class Foreman::Process

  attr_reader :entry
  attr_reader :num
  attr_reader :pid
  attr_reader :port

  def initialize(entry, num, port)
    @entry = entry
    @num = num
    @port = port
  end

  def run(pipe, basedir, environment)
    with_environment(environment.merge("PORT" => port.to_s)) do
      run_process basedir, entry.command, pipe
    end
  end

  def name
    "%s.%s" % [ entry.name, num ]
  end

  def kill(signal)
    pid && Process.kill(signal, pid)
  rescue Errno::ESRCH
    false
  end

  def detach
    pid && Process.detach(pid)
  end

  def alive?
    kill(0)
  end

  def dead?
    !alive?
  end

private

  def fork_with_io(command, basedir)
    reader, writer = IO.pipe
    command = replace_command_env(command)
    pid = if Foreman.windows?
      Dir.chdir(basedir) do
        Process.spawn command, :out => writer, :err => writer
      end
    elsif Foreman.jruby?
      require "posix/spawn"
      POSIX::Spawn.spawn(Foreman.runner, "-d", basedir, command, {
        :out => writer, :err => writer
      })
    else
      fork do
        writer.sync = true
        $stdout.reopen writer
        $stderr.reopen writer
        reader.close
        exec Foreman.runner, "-d", basedir, *command.shellsplit
      end
    end
    [ reader, pid ]
  end

  def run_process(basedir, command, pipe)
    io, @pid = fork_with_io(command, basedir)
    output pipe, "started with pid %d" % @pid
    Thread.new do
      until io.eof?
        output pipe, io.gets
      end
    end
  end

  def output(pipe, message)
    pipe.puts "%s,%s" % [ name, message ]
  end

  def replace_command_env(command)
    command.gsub(/\$(\w+)/) { |e| ENV[e[1..-1]] }
  end

  def with_environment(environment)
    original = ENV.to_hash
    ENV.update environment
    yield
  ensure
    ENV.replace original
  end
end
