require "foreman"
require "foreman/process"

class Foreman::Engine

  attr_reader :procfile
  attr_reader :directory

  def initialize(procfile)
    @procfile  = File.read(procfile)
    @directory = File.expand_path(File.dirname(procfile))
  end

  def processes
    @processes ||= begin
      procfile.split("\n").inject({}) do |hash, line|
        next if line.strip == ""
        process = Foreman::Process.new(*line.split(" ", 2))
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

    while true
      pid, status = Process.wait2
      process = running_processes.delete(pid)
      info "exited with code #{status}", process
      fork process
    end
  end

private ######################################################################

  def fork(process)
    pid = Process.fork do
      proctitle "ruby: foreman #{process.name}"

      Dir.chdir directory do
        FileUtils.mkdir_p "log"
        system "#{process.command} >>log/#{process.name}.log 2>&1"
        exit $?.exitstatus || 255
      end
    end

    info "started with pid #{pid}", process
    running_processes[pid] = process
  end

  def kill_and_exit(signal="TERM")
    info "termination requested"
    running_processes.each do |pid, process|
      info "killing pid #{pid}", process
      Process.kill(signal, pid)
    end
    exit 0
  end

  def info(message, process=nil)
    puts "[foreman] [#{Time.now.utc}] [#{process ? process.name : "system"}] #{message}"
  end

  def print_info
    info "currently running processes:"
    running_processes.each do |pid, process|
      info "pid #{pid}", process
    end
  end

  def running_processes
    @running_processes ||= {}
  end

  def proctitle(title)
    $0 = title
  end

end
