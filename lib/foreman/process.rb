require "foreman"
require "io/console"
require "shellwords"

class Foreman::Process

  @noninteractive_stdin = $stdin

  class << self
    attr_accessor :noninteractive_stdin
  end

  attr_reader :command
  attr_reader :env
  attr_reader :reader

  # Create a Process
  #
  # @param [String] command  The command to run
  # @param [Hash]   options
  #
  # @option options [String] :cwd (./)  Change to this working directory before executing the process
  # @option options [Hash]   :env ({})  Environment variables to set for this process
  #
  def initialize(command, options={})
    @command = command
    @options = options.dup

    @options[:env] ||= {}

    self.class.noninteractive_stdin = :close if options[:interactive]
  end

  # Get environment-expanded command for a +Process+
  #
  # @param [Hash] custom_env ({}) Environment variables to merge with defaults
  #
  # @return [String]  The expanded command
  #
  def expanded_command(custom_env={})
    env = @options[:env].merge(custom_env)
    expanded_command = command.dup
    env.each do |key, val|
      expanded_command.gsub!("$#{key}", val)
    end
    expanded_command
  end

  # Run a +Process+
  #
  # @param [Hash] options
  #
  # @option options :env ({}) Environment variables to set for this execution
  #
  # @returns [Fixnum] pid  The +pid+ of the process
  #
  def run(options={})
    env    = @options[:env].merge(options[:env] || {})
    runner = "#{Foreman.runner}".shellescape

    if interactive?
      $stdin.raw!
      @reader, tty = PTY.open
      Thread.new do
        loop do
          data = $stdin.readpartial(4096)
          if data.include?("\03")
            Process.kill("INT", Process.pid)
            data.gsub!("\03", "")
          end
          @reader.write(data)
        end
      end
      Process.spawn env, expanded_command(env), chdir: cwd, in: tty, out: tty, err: tty
    else
      @reader, writer = Foreman::Engine::create_pipe
      Process.spawn env, expanded_command(env), chdir: cwd, in: self.class.noninteractive_stdin, out: writer, err: writer
    end
  end

  # Exec a +Process+
  #
  # @param [Hash] options
  #
  # @option options :env ({}) Environment variables to set for this execution
  #
  # @return Does not return
  def exec(options={})
    env = @options[:env].merge(options[:env] || {})
    env.each { |k, v| ENV[k] = v }
    Dir.chdir(cwd)
    Kernel.exec expanded_command(env)
  end

  # Returns the working directory for this +Process+
  #
  # @returns [String]
  #
  def cwd
    File.expand_path(@options[:cwd] || ".")
  end

  def interactive?
    @options[:interactive]
  end
end
