require "foreman"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  class_option :procfile, :type => :string, :aliases => "-p", :desc => "Default: ./Procfile"

  desc "start [PROCESS]", "Start the application, or a specific process"

  method_option :screen,   :type => :boolean, :aliases => "-s"

  def start(process=nil)
    check_procfile!
    
    if process
      engine.execute(process)
    elsif options[:screen]
      engine.screen
    else
      engine.start
    end
  end

  desc "export FORMAT LOCATION", "Export the application to another process management format"

  method_option :app,         :type => :string, :aliases => "-a"
  method_option :log,         :type => :string, :aliases => "-l"
  method_option :user,        :type => :string, :aliases => "-u"
  method_option :concurrency, :type => :string, :aliases => "-c",
    :banner => '"alpha=5,bar=3"'

  def export(format, location=nil)
    check_procfile!

    formatter = case format
      when "upstart" then Foreman::Export::Upstart
      when "inittab" then Foreman::Export::Inittab
      else error "Unknown export format: #{format}."
    end

    formatter.new(engine).export(location,
      :name        => options[:app],
      :user        => options[:user],
      :log         => options[:log],
      :concurrency => options[:concurrency]
    )
  rescue Foreman::Export::Exception => ex
    error ex.message
  end

private ######################################################################

  def check_procfile!
    error("Procfile does not exist.") unless File.exist?(procfile)
  end

  def engine
    @engine ||= Foreman::Engine.new(procfile)
  end

  def procfile
    options[:procfile] || "./Procfile"
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
