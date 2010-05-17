require "foreman"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  desc "start [PROCFILE]", "Run the app described in PROCFILE"

  def start(procfile="Procfile")
    error "#{procfile} does not exist." unless File.exist?(procfile)
    Foreman::Engine.new(procfile).start
  end

  desc "export NAME [PROCFILE] [FORMAT]", "Export the app described in PROCFILE as NAME to another FORMAT"

  def export(name, procfile="Procfile", format="upstart")
    error "#{procfile} does not exist." unless File.exist?(procfile)

    formatter = case format
      when "upstart" then Foreman::Export::Upstart
      else error "Unknown export format: #{format}"
    end

    formatter.new(Foreman::Engine.new(procfile)).export(name)
  end

private ######################################################################

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

end
