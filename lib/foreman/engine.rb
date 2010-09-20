require "foreman"
require "foreman/process"
require "foreman/utils"
require "pty"
require "tempfile"
require "term/ansicolor"
require "fileutils"

class Foreman::Engine

  attr_reader :procfile
  attr_reader :directory

  extend Term::ANSIColor

  COLORS = [ cyan, yellow, green, magenta, red ]

  def initialize(procfile)
    @procfile  = read_procfile(procfile)
    @directory = File.expand_path(File.dirname(procfile))
  end

  def processes
    @processes ||= begin
      procfile.split("\n").inject({}) do |hash, line|
        next if line.strip == ""
        name, command = line.split(" ", 2)
        process = Foreman::Process.new(name, command)
        process.color = next_color
        hash.update(process.name => process)
      end
    end
  end

  def start(options={})
    proctitle "ruby: foreman master"

    processes.each do |name, process|
      fork process, options
    end

    trap("TERM") { kill_all("TERM") }
    trap("INT")  { kill_all("INT")  }

    watch_for_termination
  end

  def execute(name, options={})
    fork processes[name], options

    trap("TERM") { kill_all("TERM") }
    trap("INT")  { kill_all("INT")  }

    watch_for_termination
  end

  def port_for(process, num, base_port=nil)
    base_port ||= 5000
    offset = processes.keys.sort.index(process.name) * 100
    base_port.to_i + offset + num - 1
  end

private ######################################################################

  def fork(process, options={})
    concurrency = Foreman::Utils.parse_concurrency(options[:concurrency])

    1.upto(concurrency[process.name]) do |num|
      fork_individual(process, port_for(process, num, options[:port]))
    end
  end

  def fork_individual(process, port)
    ENV["PORT"] = port.to_s

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

      begin
        PTY.spawn("#{process.command} 2>&1") do |stdin, stdout, pid|
          until stdin.eof?
            info stdin.gets, process
          end
        end
      rescue PTY::ChildExited, Interrupt
        info "process exiting", process
      end
    end
  end

  def kill_all(signal="TERM")
    info "terminating"
    running_processes.each do |pid, process|
      info "killing #{process.name} in pid #{pid}"
      Process.kill(signal, pid)
    end
  end

  def info(message, process=nil)
    print process.color if process
    print "#{Time.now.strftime("%H:%M:%S")} #{pad_process_name(process)} | "
    print Term::ANSIColor.reset
    print message.chomp
    puts
  end

  def longest_process_name
    @longest_process_name ||= begin
      longest = processes.keys.map { |name| name.length }.sort.last
      longest = 6 if longest < 6 # system
      longest
    end
  end

  def pad_process_name(process)
    name = process ? "#{process.name}:#{ENV["PORT"]}" : "system"
    name.ljust(longest_process_name + 6) # add 6 for port padding
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
    kill_all
    Process.waitall
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
