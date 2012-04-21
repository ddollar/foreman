require "foreman"
require "foreman/helpers"
require "foreman/engine"
require "foreman/export"
require "thor"
require "yaml"

class Foreman::CLI < Thor
  include Foreman::Helpers

  class_option :procfile, :type => :string, :aliases => "-f", :desc => "Default: Procfile"

  desc "start [PROCESS]", "Start the application (or a specific PROCESS)"

  class_option :procfile, :type => :string, :aliases => "-f", :desc => "Default: Procfile"
  class_option :app_root, :type => :string, :aliases => "-d", :desc => "Default: Procfile directory"

  method_option :env,         :type => :string,  :aliases => "-e", :desc => "Specify an environment file to load, defaults to .env"
  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :concurrency, :type => :string,  :aliases => "-c", :banner => '"alpha=5,bar=3"'

  class << self
    # Hackery. Take the run method away from Thor so that we can redefine it.
    def is_thor_reserved_word?(word, type)
      return false if word == 'run'
      super
    end
  end

  def start(process=nil)
    check_procfile!
    engine.options[:concurrency] = "#{process}=1" if process
    engine.start
  end

  desc "export FORMAT LOCATION", "Export the application to another process management format"

  method_option :app,         :type => :string,  :aliases => "-a"
  method_option :log,         :type => :string,  :aliases => "-l"
  method_option :env,         :type => :string,  :aliases => "-e", :desc => "Specify an environment file to load, defaults to .env"
  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :user,        :type => :string,  :aliases => "-u"
  method_option :template,    :type => :string,  :aliases => "-t"
  method_option :concurrency, :type => :string,  :aliases => "-c", :banner => '"alpha=5,bar=3"'

  def export(format, location=nil)
    check_procfile!
    formatter = Foreman::Export.formatter(format)
    formatter.new(location, engine, options).export
  rescue Foreman::Export::Exception => ex
    error ex.message
  end

  desc "check", "Validate your application's Procfile"

  def check
    check_procfile!
    error "no processes defined" unless engine.procfile.entries.length > 0
    puts "valid procfile detected (#{engine.procfile.process_names.join(', ')})"
  end

  desc "run COMMAND", "Run a command using your application's environment"

  def run(*args)
    engine.apply_environment!
    begin
      exec args.join(" ")
    rescue Errno::EACCES
      error "not executable: #{args.first}"
    rescue Errno::ENOENT
      error "command not found: #{args.first}"
    end
  end

private ######################################################################

  def check_procfile!
    error("#{procfile} does not exist.") unless File.exist?(procfile)
  end

  def engine
    root = File.expand_path(File.dirname(procfile))
    env = File.expand_path(File.join(root, ".env"))
    @engine ||= Foreman::Engine.new(procfile, options.merge({:app_root => root,
                                                             :env => env}))
  end

  def procfile
    options[:procfile] || "Procfile"
  end

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

  def options
    original_options = super
    return original_options unless File.exists?(".foreman")
    defaults = YAML::load_file(".foreman") || {}
    Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
  end
end
