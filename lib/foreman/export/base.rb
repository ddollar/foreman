require "foreman/export"
require "foreman/utils"

class Foreman::Export::Base

  attr_reader :location, :engine, :app, :log, :port, :user, :template
  attr_reader :concurrency, :alert_on_mem, :restart_on_mem, :alert_on_cpu, :restart_on_cpu

  def initialize(location, engine, options={})
    @location    = location || default_location
    @engine      = engine
    @app         = options[:app]
    @log         = options[:log]
    @port        = options[:port]
    @user        = options[:user]
    @template    = options[:template]

    @concurrency    = Foreman::Utils.parse_concurrency(options[:concurrency])
    @alert_on_mem   = Foreman::Utils.parse_process_attribute(options[:"alert-on-mem"])
    @restart_on_mem = Foreman::Utils.parse_process_attribute(options[:"restart-on-mem"])
    @alert_on_cpu   = Foreman::Utils.parse_process_attribute(options[:"alert-on-cpu"])
    @restart_on_cpu = Foreman::Utils.parse_process_attribute(options[:"restart-on-cpu"])
  end

  def export
    raise "export method must be overridden"
  end
  
protected ####################################################################

  def default_location
    nil
  end

private ######################################################################

  def error(message)
    raise Foreman::Export::Exception.new(message)
  end

  def say(message)
    puts "[foreman export] %s" % message
  end

  def export_template(exporter, file, template_root)
    if template_root && File.exist?(file_path = File.join(template_root, file))
      File.read(file_path)
    elsif File.exist?(file_path = File.expand_path(File.join("~/.foreman/templates", file)))
      File.read(file_path)
    else
      File.read(File.expand_path("../../../../data/export/#{exporter}/#{file}", __FILE__))
    end
  end

  def write_file(filename, contents)
    say "writing: #{filename}"

    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

  # Quote a string to be used on the command line. Backslashes are escapde to \\ and quotes 
  # escaped to \"
  #
  #   str - string to be quoted
  #
  # Examples
  # 
  #  shell_quote("FB|123\"\\1")
  #  # => "\"FB|123\"\\"\\\\1\""
  #
  # Returns the the escaped string surrounded by quotes 
  def shell_quote(str)
    "\"#{str.gsub(/\\/){ '\\\\' }.gsub(/["]/){ "\\\"" }}\""
  end

end
