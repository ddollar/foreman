require "foreman/export"
require "foreman/utils"

class Foreman::Export::Base

  attr_reader :engine
  attr_accessor :template

  def initialize(engine)
    @engine = engine
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

  def export_template(path, file)
    if template and File.exist?(file_path = File.join(template, file))
      File.read(file_path)
    else
      File.read(File.expand_path("../../../../data/export/#{path}/#{file}", __FILE__))
    end
  end

  def write_file(filename, contents)
    say "writing: #{filename}"

    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

end
