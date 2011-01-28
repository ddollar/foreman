require "foreman"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  class_option :procfile, :type => :string, :aliases => "-f", :desc => "Default: Procfile"

  desc "start [PROCESS]", "Start the application, or a specific process"

  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :concurrency, :type => :string,  :aliases => "-c",
    :banner => '"alpha=5,bar=3"'

  def start(process=nil)
    check_procfile!

    if process
      engine.execute(process, options)
    else
      engine.start(options)
    end
  end

  desc "export FORMAT LOCATION", "Export the application to another process management format"

  method_option :app,         :type => :string,  :aliases => "-a"
  method_option :log,         :type => :string,  :aliases => "-l"
  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :user,        :type => :string,  :aliases => "-u"
  method_option :concurrency, :type => :string,  :aliases => "-c",
    :banner => '"alpha=5,bar=3"'

  def export(format, location=nil)
    check_procfile!

    formatter = case format
      when "json"    then Foreman::Export::JSON
      when "inittab" then Foreman::Export::Inittab
      when "upstart" then Foreman::Export::Upstart
      else error "Unknown export format: #{format}."
    end

    formatter.new(engine).export(location, options)

  rescue Foreman::Export::Exception => ex
    error ex.message
  end

private ######################################################################

  def check_procfile!
    error("#{procfile} does not exist.") unless File.exist?(procfile)
  end

  def engine
    @engine ||= Foreman::Engine.new(procfile)
  end

  def procfile
    options[:procfile] || "Procfile"
  end

private ######################################################################

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

  def procfile_exists?(procfile)
    File.exist?(procfile)
  end

end
