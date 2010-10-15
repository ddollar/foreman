require "foreman"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  class_option :pstypes, :type => :string, :aliases => "-f", :desc => "Default: Pstypes"

  desc "start [PROCESS]", "Start the application, or a specific process"

  method_option :port,        :type => :numeric, :aliases => "-p"
  method_option :concurrency, :type => :string,  :aliases => "-c",
    :banner => '"alpha=5,bar=3"'

  def start(process=nil)
    check_pstypes!

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
    check_pstypes!

    formatter = case format
      when "upstart" then Foreman::Export::Upstart
      when "inittab" then Foreman::Export::Inittab
      else error "Unknown export format: #{format}."
    end

    formatter.new(engine).export(location, options)

  rescue Foreman::Export::Exception => ex
    error ex.message
  end

private ######################################################################

  def check_pstypes!
    error("#{pstypes} does not exist.") unless File.exist?(pstypes)
  end

  def engine
    @engine ||= Foreman::Engine.new(pstypes)
  end

  def pstypes
    options[:pstypes] || "Pstypes"
  end

private ######################################################################

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

  def pstypes_exists?(pstypes)
    File.exist?(pstypes)
  end

end
