require "foreman"

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
    Dir.chdir(basedir) do
      with_environment(environment.merge("PORT" => port.to_s)) do
        run_process entry.command, pipe
      end
    end
  end

  def name
    "%s.%s" % [ entry.name, num ]
  end

private

  def fork_with_io(command)
    reader, writer = IO.pipe
    pid = fork do
      trap("INT", "IGNORE")
      writer.sync = true
      $stdout.reopen writer
      $stderr.reopen writer
      reader.close
      exec Foreman.runner, replace_command_env(command)
    end
    [ reader, pid ]
  end

  def run_process(command, pipe)
    io, @pid = fork_with_io(command)
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
