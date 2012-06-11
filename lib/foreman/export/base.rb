require "foreman/export"
require "shellwords"

class Foreman::Export::Base

  attr_reader :location
  attr_reader :engine
  attr_reader :options
  attr_reader :formation

  def initialize(location, engine, options={})
    @location  = location
    @engine    = engine
    @options   = options.dup
    @formation = engine.formation
  end

  def export
    error("Must specify a location") unless location
    FileUtils.mkdir_p(location) rescue error("Could not create: #{location}")
    FileUtils.mkdir_p(log) rescue error("Could not create: #{log}")
    FileUtils.chown(user, nil, log) rescue error("Could not chown #{log} to #{user}")
  end

  def app
    options[:app] || "app"
  end

  def log
    options[:log] || "/var/log/#{app}"
  end

  def user
    options[:user] || app
  end

private ######################################################################

  def error(message)
    raise Foreman::Export::Exception.new(message)
  end

  def say(message)
    puts "[foreman export] %s" % message
  end
  
  def clean(filename)
    return unless File.exists?(filename)
    say "cleaning up: #{filename}"
    FileUtils.rm(filename)
  end

  def shell_quote(value)
    '"' + Shellwords.escape(value) + '"'
  end

  def export_template(name)
    name_without_first = name.split("/")[1..-1].join("/")
    matchers = []
    matchers << File.join(options[:template], name_without_first) if options[:template]
    matchers << File.expand_path("~/.foreman/templates/#{name}")
    matchers << File.expand_path("../../../../data/export/#{name}", __FILE__)
    File.read(matchers.detect { |m| File.exists?(m) })
  end

  def write_template(name, target, binding)
    compiled = ERB.new(export_template(name)).result(binding)
    write_file target, compiled
  end

  def chmod(mode, file)
    say "setting #{file} to mode #{mode}"
    FileUtils.chmod mode, File.join(location, file)
  end

  def create_directory(dir)
    say "creating: #{dir}"
    FileUtils.mkdir_p(File.join(location, dir))
  end

  def write_file(filename, contents)
    say "writing: #{filename}"

    File.open(File.join(location, filename), "w") do |file|
      file.puts contents
    end
  end

end
