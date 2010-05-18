require "foreman"
require "foreman/configuration"
require "foreman/engine"
require "foreman/export"
require "thor"

class Foreman::CLI < Thor

  desc "start [PROCFILE]", "Run the app described in PROCFILE"

  def start(procfile="Procfile")
    error "#{procfile} does not exist." unless File.exist?(procfile)
    Foreman::Engine.new(procfile).start
  end

  desc "export APP [PROCFILE] [FORMAT]", "Export the app described in PROCFILE as APP to another FORMAT"

  def export(app, procfile="Procfile", format="upstart")
    error "#{procfile} does not exist." unless File.exist?(procfile)

    formatter = case format
      when "upstart" then Foreman::Export::Upstart
      else error "Unknown export format: #{format}"
    end

    formatter.new(Foreman::Engine.new(procfile)).export(app)
  end

  desc "scale APP PROCESS AMOUNT", "Change the concurrency of a given process type"

  def scale(app, process, amount)
    config = Foreman::Configuration.new(app)

    amount = amount.to_i
    old_amount = config.processes[process]

    config.scale(process, amount)

    if (old_amount < amount)
      ((old_amount+1)..amount).each { |num| system "start #{app}-#{process} NUM=#{num}" }
    elsif (amount < old_amount)
      ((amount+1)..old_amount).each { |num| system "stop #{app}-#{process} NUM=#{num}" }
    end

    config.write
  end

private ######################################################################

  def error(message)
    puts "ERROR: #{message}"
    exit 1
  end

end
