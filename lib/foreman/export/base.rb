require "foreman/export"
require "foreman/utils"

class Foreman::Export::Base

  attr_reader :engine

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

  def export_template(name)
    File.read(File.expand_path("../../../../data/export/#{name}", __FILE__))
  end

  def write_file(filename, contents)
    say "writing: #{filename}"

    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

end
