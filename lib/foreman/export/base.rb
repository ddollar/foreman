require "foreman/export"
require "foreman/utils"

class Foreman::Export::Base

  attr_reader :engine, :location, :options, :app, :user, :log_root, :template_root, :concurrency

  def initialize(engine, location, opts={})
    @engine        = engine
    @location      = location
    @options       = opts
    @app           = options[:app]  || File.basename(engine.directory)
    @user          = options[:user] || app
    @log_root      = options[:log]  || "/var/log/#{app}"
    @template_root = options[:template]
    @concurrency   = Foreman::Utils.parse_concurrency(options[:concurrency])

    FileUtils.mkdir_p File.dirname(location)
  end

  def export
    raise "export method must be overridden"
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
    elsif File.exist?(file_path = File.join("~/.foreman/templates", file))
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
end
