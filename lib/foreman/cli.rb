require "foreman"
require "foreman/engine"
require "foreman/export"
require "thor"
require "yaml"

class Foreman::CLI < Thor

  desc "start", "Start the application"

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

  def start
    check_procfile!
    engine.start
  end

  desc "export FORMAT LOCATION", "Export the application to another process management format"

  method_option :app,         :type => :string,  :aliases => "-a"
  method_option :log,         :type => :string,  :aliases => "-l"
  method_option :env,         :type => :string,  :aliases => "-e", :desc => "Specify an environment file to load, defaults to .env"
  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :user,        :type => :string,  :aliases => "-u"
  method_option :template,    :type => :string,  :aliases => "-t"
  method_option :concurrency, :type => :string,  :aliases => "-c",
    :banner => '"alpha=5,bar=3"'

  def export(format, location=nil)
    check_procfile!

    formatter = case format
      when "inittab" then Foreman::Export::Inittab
      when "upstart" then Foreman::Export::Upstart
      when "bluepill" then Foreman::Export::Bluepill
      when "runit"    then Foreman::Export::Runit
      else error "Unknown export format: #{format}."
    end

    formatter.new(engine).export(location, options)

  rescue Foreman::Export::Exception => ex
    error ex.message
  end

  desc "check", "Validate your application's Procfile"

  def check
    error "no processes defined" unless engine.procfile.entries.length > 0
    display "valid procfile detected (#{engine.procfile.process_names.join(', ')})"
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
    @engine ||= Foreman::Engine.new(procfile, options)
  end

  def procfile
    options[:procfile] || "Procfile"
  end

  def display(message)
    puts message
  end

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

  def procfile_exists?(procfile)
    File.exist?(procfile)
  end

  def options
    original_options = super
    return original_options unless File.exists?(".foreman")
    defaults = YAML::load_file(".foreman") || {}
    Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
  end
end
