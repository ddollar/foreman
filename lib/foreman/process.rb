require "foreman"
require "shellwords"

class Foreman::Process

  attr_reader :command
  attr_reader :env

  # Create a Process
  #
  # @param [String] command  The command to run
  # @param [Hash]   options
  #
  # @option options [String]  :cwd                   (./)     Change to this working directory before executing the process
  # @option options [Hash]    :env                   ({})     Environment variables to set for this process
  # @option options [Boolean] :keep_file_descriptors (false)  Inherit file descriptors
  #
  def initialize(command, options={})
    @command = command
    @options = options.dup

    @options[:env] ||= {}
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
  # @option options :env                      ({})       Environment variables to set for this execution
  # @option options :output                   ($stdout)  The output stream
  # @option options :keep_file_descriptors    (false)    Keep file descriptors
  #
  # @returns [Fixnum] pid  The +pid+ of the process
  #
  def run(options={})
    env                   = @options[:env].merge(options[:env] || {})
    output                = options[:output] || $stdout
    keep_file_descriptors = @options[:keep_file_descriptors] || options[:keep_file_descriptors]
    runner                = "#{Foreman.runner}".shellescape
    
    Dir.chdir(cwd) do
      Process.spawn env, expanded_command(env), :out => output, :err => output, :close_others => !keep_file_descriptors
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

end
