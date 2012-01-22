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

private

  def jruby?
    defined?(RUBY_PLATFORM) and RUBY_PLATFORM == "java"
  end

  def fork_with_io(command, basedir)
    reader, writer = IO.pipe
    command = replace_command_env(command)
    pid = if jruby?
      require "spoon"
      Spoon.spawnp Foreman.runner, "-d", basedir, command
    else
      fork do
        trap("INT", "IGNORE")
        writer.sync = true
        $stdout.reopen writer
        $stderr.reopen writer
        reader.close
        exec Foreman.runner, "-d", basedir, command
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
    old_env = ENV.each_pair.inject({}) { |h,(k,v)| h.update(k => v) }
    environment.each { |k,v| ENV[k] = v }
    ret = yield
    ENV.clear
    old_env.each { |k,v| ENV[k] = v}
    ret
  end

end
