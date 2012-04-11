require "foreman"
require "foreman/color"
require "foreman/process"
require "foreman/procfile"
require "foreman/utils"
require "tempfile"
require "timeout"
require "fileutils"
require "thread"

class Foreman::Engine

  attr_reader :environment
  attr_reader :procfile
  attr_reader :directory
  attr_reader :options

  COLORS = %w( cyan yellow green magenta red blue intense_cyan intense_yellow
               intense_green intense_magenta intense_red, intense_blue )

  Foreman::Color.enable($stdout)

  def initialize(procfile, options={})
    @procfile  = Foreman::Procfile.new(procfile)
    @directory = options[:app_root] || File.expand_path(File.dirname(procfile))
    @options = options.dup
    @environment = read_environment_files(options[:env])
    @output_mutex = Mutex.new
  end

  def run
    proctitle "ruby: foreman master"
    termtitle "#{File.basename(@directory)} - foreman"

    trap("TERM") { puts "SIGTERM received"; terminate_gracefully }
    trap("INT")  { puts "SIGINT received";  terminate_gracefully }

    assign_colors
    spawn_processes
    watch_for_output
    watch_for_termination
    terminate_gracefully
  end

  def stop(name, signal='SIGTERM')
    running_processes.each do |pid, process|
      unless name.nil?
        # Comparing against process.entry.name instead of process.name to
        # make sure we match the process name exactly for any/all
        # concurrently running processes by this name
        next unless process.entry.name == name
      else
        info "sending #{signal} to all processes"
      end

      process.kill signal
      process = running_processes.delete(pid)
      Timeout.timeout(5) do
        begin
          Process.waitpid(pid)
          info "process terminated", process.name
        rescue Errno::ECHILD
        end
      end
    end
  end

  def port_for(process, num, base_port=nil)
    base_port ||= 5000
    offset = procfile.process_names.index(process.name) * 100
    base_port.to_i + offset + num - 1
  end

  def apply_environment!
    environment.each { |k,v| ENV[k] = v }
  end

private ######################################################################

  def spawn_processes
    concurrency = Foreman::Utils.parse_concurrency(@options[:concurrency])

    procfile.entries.each do |entry|
      reader, writer = (IO.method(:pipe).arity == 0 ? IO.pipe : IO.pipe("BINARY"))
      entry.spawn(concurrency[entry.name], writer, @directory, @environment, port_for(entry, 1, base_port)).each do |process|
        running_processes[process.pid] = process
        readers[process] = reader
      end
    end
  end

  def base_port
    options[:port] || 5000
  end

  def terminate_gracefully
    return if @terminating
    @terminating = true
    Timeout.timeout(5) do
      stop(nil)
    end
  rescue Timeout::Error
    stop(nil, 'SIGKILL')
  rescue Errno::ECHILD
  end

  def poll_readers
    rs, ws = IO.select(readers.values, [], [], 1)
    (rs || []).each do |r|
      data = r.gets
      next unless data
      data.force_encoding("BINARY") if data.respond_to?(:force_encoding)
      ps, message = data.split(",", 2)
      color = colors[ps.split(".").first]
      info message, ps, color
    end
  end

  def watch_for_output
    Thread.new do
      require "win32console" if Foreman.windows?
      begin
        loop do
          poll_readers
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
  rescue Errno::ECHILD
  end

  def info(message, name="system", color=:white)
    output  = ""
    output += $stdout.color(color)
    output += "#{Time.now.strftime("%H:%M:%S")} #{pad_process_name(name)} | "
    output += $stdout.color(:reset)
    output += message.chomp
    puts output
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
    printf("\033]0;#{title}\007") unless Foreman.windows?
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
    procfile.entries.each_with_index do |entry, idx|
      colors[entry.name] = COLORS[idx % COLORS.length]
    end
  end

  def process_by_reader(reader)
    readers.invert[reader]
  end

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
        key, val = [$1, $2]
        case val
          when /\A'(.*)'\z/ then hash[key] = $1
          when /\A"(.*)"\z/ then hash[key] = $1.gsub(/\\(.)/, '\1')
          else hash[key] = val
        end
      end
      hash
    end
  end
end
