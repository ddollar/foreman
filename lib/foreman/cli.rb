require "foreman"
require "foreman/configuration"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  desc "start [PROCFILE]", "Run the app described in PROCFILE"

  def start(procfile="Procfile")
    error "#{procfile} does not exist." unless procfile_exists?(procfile)
    Foreman::Engine.new(procfile).start
  end

  desc "export APP [PROCFILE] [FORMAT]", "Export the app described in PROCFILE as APP to another FORMAT"

  def export(app, procfile="Procfile", format="upstart")
    error "#{procfile} does not exist." unless procfile_exists?(procfile)

    formatter = case format
      when "upstart" then Foreman::Export::Upstart
      else error "Unknown export format: #{format}."
    end

    formatter.new(Foreman::Engine.new(procfile)).export(app)
  end

  desc "scale APP PROCESS AMOUNT", "Change the concurrency of a given process type"

  def scale(app, process, amount)
    Foreman::Configuration.new(app).scale(process, amount)
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
