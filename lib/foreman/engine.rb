require "foreman"
require "foreman/process"
require "foreman/procfile"
require "foreman/utils"
require "pty"
require "tempfile"
require "timeout"
require "term/ansicolor"
require "fileutils"
require "thread"

class Foreman::Engine

  attr_reader :procfile
  attr_reader :directory
  attr_reader :options

  extend Term::ANSIColor

  COLORS = [ cyan, yellow, green, magenta, red, blue,
             intense_cyan, intense_yellow, intense_green, intense_magenta,
             intense_red, intense_blue ]

  def initialize(procfile, options={})
    @procfile  = Foreman::Procfile.new(procfile)
    @directory = options[:app_root] || File.expand_path(File.dirname(procfile))
    @options = options
    @environment = read_environment_files(options[:env])
    @output_mutex = Mutex.new
  end

  def self.load_env!(env_file)
    @environment = read_environment_files(env_file)
    apply_environment!
  end

  def start
    proctitle "ruby: foreman master"
    termtitle "#{File.basename(@directory)} - foreman"

    trap("TERM") { puts "SIGTERM received"; terminate_gracefully }
    trap("INT")  { puts "SIGINT received";  terminate_gracefully }

    assign_colors
    spawn_processes
    watch_for_output
    watch_for_termination
  end

  def port_for(process, num, base_port=nil)
    base_port ||= 5000
    offset = procfile.process_names.index(process.name) * 100
    base_port.to_i + offset + num - 1
  end

private ######################################################################

  def spawn_processes
    concurrency = Foreman::Utils.parse_concurrency(@options[:concurrency])

    procfile.entries.each do |entry|
      reader, writer = IO.pipe
      entry.spawn(concurrency[entry.name], writer, @directory, @environment, port_for(entry, 1, base_port)).each do |process|
        running_processes[process.pid] = process
        readers[process] = reader
      end
    end
  end

  def base_port
    options[:port] || 5000
  end

  def kill_all(signal="SIGTERM")
    running_processes.each do |pid, process|
      info "sending #{signal} to pid #{pid}"
      Process.kill(signal, pid) rescue Errno::ESRCH
    end
  end

  def terminate_gracefully
    info "sending SIGTERM to all processes"
    kill_all "SIGTERM"
    Timeout.timeout(5) { Process.waitall }
  rescue Timeout::Error
    info "sending SIGKILL to all processes"
    kill_all "SIGKILL"
  end

  def watch_for_output
    Thread.new do
      begin
        loop do
          rs, ws = IO.select(readers.values, [], [], 1)
          (rs || []).each do |r|
            ps, message = r.gets.split(",", 2)
            color = colors[ps.split(".").first]
            info message, ps, color
          end
        end
      rescue Exception => ex
        puts ex.message
        puts ex.backtrace
      end
    end
  end

  def watch_for_termination
    pid, status = Process.wait2
    process = running_processes.delete(pid)
    info "process terminated", process.name
    terminate_gracefully
    kill_all
  rescue Errno::ECHILD
  end

  def info(message, name="system", color=Term::ANSIColor.white)
    print color
    print "#{Time.now.strftime("%H:%M:%S")} #{pad_process_name(name)} | "
    print Term::ANSIColor.reset
    print message.chomp
    puts ""
  end

  def print(message=nil)
    @output_mutex.synchronize do
      $stdout.print message
    end
  end

  def puts(message=nil)
    @output_mutex.synchronize do
      $stdout.puts message
    end
  end

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

  def longest_process_name
    @longest_process_name ||= begin
      longest = procfile.process_names.map { |name| name.length }.sort.last
      longest = 6 if longest < 6 # system
      longest
    end
  end

  def pad_process_name(name="system")
    name.to_s.ljust(longest_process_name + 3) # add 3 for process number padding
  end

  def proctitle(title)
    $0 = title
  end

  def termtitle(title)
    printf("\033]0;#{title}\007")
  end

  def running_processes
    @running_processes ||= {}
  end

  def readers
    @readers ||= {}
  end

  def colors
    @colors ||= {}
  end

  def assign_colors
    procfile.entries.each do |entry|
      colors[entry.name] = next_color
    end
  end

  def process_by_reader(reader)
    readers.invert[reader]
  end

  def next_color
    @current_color ||= -1
    @current_color  +=  1
    @current_color = 0 if COLORS.length < @current_color
    COLORS[@current_color]
  end

  module Env
    attr_reader :environment

    def read_environment_files(filenames)
      environment = {}

      (filenames || "").split(",").map(&:strip).each do |filename|
        error "No such file: #{filename}" unless File.exists?(filename)
        environment.merge!(read_environment(filename))
      end

      environment.merge!(read_environment(".env")) unless filenames
      environment
    end

    def read_environment(filename)
      return {} unless File.exists?(filename)

      File.read(filename).split("\n").inject({}) do |hash, line|
        if line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
          hash[$1] = $2
        end
        hash
      end
    end

    def apply_environment!
      @environment.each { |k,v| ENV[k] = v }
    end
  end

  include Env
  extend  Env
end
