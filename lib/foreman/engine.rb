require "foreman"
require "foreman/env"
require "foreman/process"
require "foreman/procfile"
require "tempfile"
require "timeout"
require "fileutils"
require "thread"

class Foreman::Engine

  attr_reader :env
  attr_reader :options
  attr_reader :processes

  # Create an +Engine+ for running processes
  #
  # @param [Hash] options
  #
  # @option options [String] :formation (all=1)    The process formation to use
  # @option options [Fixnum] :port      (5000)     The base port to assign to processes
  # @option options [String] :root      (Dir.pwd)  The root directory from which to run processes
  #
  def initialize(options={})
    @options = options.dup

    @options[:formation] ||= (options[:concurrency] || "all=1")

    @env       = {}
    @mutex     = Mutex.new
    @names     = {}
    @processes = []
    @running   = {}
    @readers   = {}
  end

  # Start the processes registered to this +Engine+
  #
  def start
    trap("TERM") { puts "SIGTERM received"; terminate_gracefully }
    trap("INT")  { puts "SIGINT received";  terminate_gracefully }
    trap("HUP")  { puts "SIGHUP received";  terminate_gracefully } if ::Signal.list.keys.include? 'HUP'

    startup
    spawn_processes
    watch_for_output
    sleep 0.1
    watch_for_termination { terminate_gracefully }
    shutdown
  end

  # Register a process to be run by this +Engine+
  #
  # @param [String] name     A name for this process
  # @param [String] command  The command to run
  # @param [Hash]   options
  #
  # @option options [Hash] :env  A custom environment for this process
  #
  def register(name, command, options={})
    options[:env] ||= env
    options[:cwd] ||= File.dirname(command.split(" ").first)
    process = Foreman::Process.new(command, options)
    @names[process] = name
    @processes << process
  end

  # Clear the processes registered to this +Engine+
  #
  def clear
    @names     = {}
    @processes = []
  end

  # Register processes by reading a Procfile
  #
  # @param [String] filename  A Procfile from which to read processes to register
  #
  def load_procfile(filename)
    options[:root] ||= File.dirname(filename)
    Foreman::Procfile.new(filename).entries do |name, command|
      register name, command, :cwd => options[:root]
    end
    self
  end

  # Load a .env file into the +env+ for this +Engine+
  #
  # @param [String] filename  A .env file to load into the environment
  #
  def load_env(filename)
    Foreman::Env.new(filename).entries do |name, value|
      @env[name] = value
    end
  end

  # Send a signal to all processesstarted by this +Engine+
  #
  # @param [String] signal  The signal to send to each process
  #
  def killall(signal="SIGTERM")
    if Foreman.windows?
      @running.each do |pid, (process, index)|
        system "sending #{signal} to #{name_for(pid)} at pid #{pid}"
        begin
          Process.kill(signal, pid)
        rescue Errno::ESRCH, Errno::EPERM
        end
      end
    else
      begin
        Process.kill "-#{signal}", Process.pid
      rescue Errno::ESRCH, Errno::EPERM
      end
    end
  end

  # Get the process formation
  #
  # @returns [Fixnum]  The formation count for the specified process
  #
  def formation
    @formation ||= parse_formation(options[:formation])
  end

  # List the available process names
  #
  # @returns [Array]  A list of process names
  #
  def process_names
    @processes.map { |p| @names[p] }
  end

  # Get the +Process+ for a specifid name
  #
  # @param [String] name  The process name
  #
  # @returns [Foreman::Process]  The +Process+ for the specified name
  #
  def process(name)
    @names.invert[name]
  end

  # Yield each +Process+ in order
  #
  def each_process
    process_names.each do |name|
      yield name, process(name)
    end
  end

  # Get the root directory for this +Engine+
  #
  # @returns [String]  The root directory
  #
  def root
    File.expand_path(options[:root] || Dir.pwd)
  end

  # Get the port for a given process and offset
  #
  # @param [Foreman::Process] process   A +Process+ associated with this engine
  # @param [Fixnum]           instance  The instance of the process
  #
  # @returns [Fixnum] port  The port to use for this instance of this process
  #
  def port_for(process, instance, base=nil)
    if base
      base + (@processes.index(process.process) * 100) + (instance - 1)
    else
      base_port + (@processes.index(process) * 100) + (instance - 1)
    end
  end

  # Get the base port for this foreman instance
  #
  # @returns [Fixnum] port  The base port
  #
  def base_port
    (options[:port] || env["PORT"] || ENV["PORT"] || 5000).to_i
  end

  # deprecated
  def environment
    env
  end

private

### Engine API ######################################################

  def startup
    raise TypeError, "must use a subclass of Foreman::Engine"
  end

  def output(name, data)
    raise TypeError, "must use a subclass of Foreman::Engine"
  end

  def shutdown
    raise TypeError, "must use a subclass of Foreman::Engine"
  end

## Helpers ##########################################################

  def create_pipe
    IO.method(:pipe).arity.zero? ? IO.pipe : IO.pipe("BINARY")
  end

  def name_for(pid)
    process, index = @running[pid]
    [ @names[process], index.to_s ].compact.join(".")
  end

  def parse_formation(formation)
    pairs = formation.to_s.gsub(/\s/, "").split(",")

    pairs.inject(Hash.new(0)) do |ax, pair|
      process, amount = pair.split("=")
      process == "all" ? ax.default = amount.to_i : ax[process] = amount.to_i
      ax
    end
  end

  def output_with_mutex(name, message)
    @mutex.synchronize do
      output name, message
    end
  end

  def system(message)
    output_with_mutex "system", message
  end

  def termination_message_for(status)
    if status.exited?
      "exited with code #{status.exitstatus}"
    elsif status.signaled?
      "terminated by SIG#{Signal.list.invert[status.termsig]}"
    else
      "died a mysterious death"
    end
  end

  def flush_reader(reader)
    until reader.eof?
      data = reader.gets
      output_with_mutex name_for(@readers.key(reader)), data
    end
  end

## Engine ###########################################################

  def spawn_processes
    @processes.each do |process|
      1.upto(formation[@names[process]]) do |n|
        reader, writer = create_pipe
        begin
          pid = process.run(:output => writer, :env => {
            "PORT" => port_for(process, n).to_s
          })
          writer.puts "started with pid #{pid}"
        rescue Errno::ENOENT
          writer.puts "unknown command: #{process.command}"
        end
        @running[pid] = [process, n]
        @readers[pid] = reader
      end
    end
  end

  def watch_for_output
    Thread.new do
      begin
        loop do
          io = IO.select(@readers.values, nil, nil, 30)
          (io.nil? ? [] : io.first).each do |reader|
            data = reader.gets
            output_with_mutex name_for(@readers.invert[reader]), data
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
    output_with_mutex name_for(pid), termination_message_for(status)
    @running.delete(pid)
    yield if block_given?
    pid
  rescue Errno::ECHILD
  end

  def terminate_gracefully
    return if @terminating
    @terminating = true
    if Foreman.windows?
      system  "sending SIGKILL to all processes"
      killall "SIGKILL"
    else
      system  "sending SIGTERM to all processes"
      killall "SIGTERM"
    end
    Timeout.timeout(5) do
      watch_for_termination while @running.length > 0
    end
  rescue Timeout::Error
    system  "sending SIGKILL to all processes"
    killall "SIGKILL"
  end

end
