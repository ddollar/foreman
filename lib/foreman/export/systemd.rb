require "erb"
require "foreman/export"

class Foreman::Export::Systemd < Foreman::Export::Base

  def export
    super

    Dir["#{location}/#{app}*.target"].concat(Dir["#{location}/#{app}*.service"]).each do |file|
      clean file
    end

    process_master_names = []

    engine.each_process do |name, process|
      write_template "systemd/process.service.erb", "#{app}-#{name}@.service", binding

      process_names = 1.upto(engine.formation[name])
                        .collect { |num| engine.port_for(process, num) }
                        .collect { |port| "#{app}-#{name}@#{port}.service" }

      write_template "systemd/process_master.target.erb", "#{app}-#{name}.target", binding
      process_master_names << "#{app}-#{name}.target"
    end

    write_template "systemd/master.target.erb", "#{app}.target", binding
  end
end
