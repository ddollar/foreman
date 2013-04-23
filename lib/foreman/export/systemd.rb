require "erb"
require "foreman/export"

class Foreman::Export::Systemd < Foreman::Export::Base

  def export
    super

    Dir["#{location}/#{app}*.target"].concat(Dir["#{location}/#{app}*.service"]).each do |file|
      clean file
    end

    write_template "systemd/master.target.erb", "#{app}.target", binding

    engine.each_process do |name, process|
      next if engine.formation[name] < 1
      write_template "systemd/process_master.target.erb", "#{app}-#{name}.target", binding

      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        write_template "systemd/process.service.erb", "#{app}-#{name}-#{num}.service", binding
      end
    end
  end
end
