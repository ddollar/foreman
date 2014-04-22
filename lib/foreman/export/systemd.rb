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
      next if engine.formation[name] < 1

      process_names = []

      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        write_template "systemd/process.service.erb", "#{app}-#{name}-#{num}.service", binding
        process_names << "#{app}-#{name}-#{num}.service"
      end

      write_template "systemd/process_master.target.erb", "#{app}-#{name}.target", binding
      process_master_names << "#{app}-#{name}.target"
    end

    write_template "systemd/master.target.erb", "#{app}.target", binding
  end
end
