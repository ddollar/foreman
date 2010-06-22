require "foreman"
require "foreman/process"
require "pty"
require "tempfile"
require "term/ansicolor"

class Foreman::Engine

  attr_reader :procfile
  attr_reader :directory

  extend Term::ANSIColor

  COLORS = [ cyan, yellow, green, magenta, on_blue ]

  def initialize(procfile)
    @procfile  = read_procfile(procfile)
    @directory = File.expand_path(File.dirname(procfile))
  end

  def processes
    @processes ||= begin
      procfile.split("\n").inject({}) do |hash, line|
        next if line.strip == ""
        process = Foreman::Process.new(*line.split(" ", 2))
        process.color = next_color
        hash.update(process.name => process)
      end
    end
  end

  def start
    proctitle "ruby: foreman master"

    processes.each do |name, process|
      fork process
    end

    trap("TERM") { kill_and_exit("TERM") }
    trap("INT")  { kill_and_exit("INT")  }

    watch_for_termination
  end

  def screen
    tempfile = Tempfile.new("foreman")
    tempfile.puts "sessionname foreman"
    processes.each do |name, process|
      tempfile.puts "screen -t #{name} #{process.command}"
    end
    tempfile.close

    system "screen -c #{tempfile.path}"

    tempfile.delete
  end

  def execute(name)
    run(processes[name], false)
  end

private ######################################################################

  def fork(process)
    pid = Process.fork do
      run(process)
    end

    info "started with pid #{pid}", process
    running_processes[pid] = process
  end

  def run(process, log_to_file=true)
    proctitle "ruby: foreman #{process.name}"

    Dir.chdir directory do
      FileUtils.mkdir_p "log"
      command = process.command

      PTY.spawn("#{process.command} 2>&1") do |stdin, stdout, pid|
        until stdin.eof?
          info stdin.gets, process
        end
      end
    end
  end

  def kill_and_exit(signal="TERM")
    info "terminating"
    running_processes.each do |pid, process|
      info "killing #{process.name} in pid #{pid}"
      Process.kill(signal, pid)
    end
    exit 0
  end

  def info(message, process=nil)
    print process.color if process
    print "[#{Time.now.strftime("%H:%M:%S")}] [#{process ? process.name : "system"}] #{message.chomp}"
    print Term::ANSIColor.reset
    puts
  end

  def print_info
    info "currently running processes:"
    running_processes.each do |pid, process|
      info "pid #{pid}", process
    end
  end

  def proctitle(title)
    $0 = title
  end

  def read_procfile(procfile)
    File.read(procfile)
  end

  def watch_for_termination
    pid, status = Process.wait2
    process = running_processes.delete(pid)
    info "process terminated", process
    kill_and_exit
  end

  def running_processes
    @running_processes ||= {}
  end

  def next_color
    @current_color ||= -1
    @current_color  +=  1
    @current_color >= COLORS.length ? "" : COLORS[@current_color]
  end

end
