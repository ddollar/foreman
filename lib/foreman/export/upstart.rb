require "erb"
require "foreman/export"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export
    super

    (Dir["#{location}/#{app}-*.conf"] << "#{location}/#{app}.conf").each do |file|
      clean file
    end

    write_template master_template, "#{app}.conf", binding

    engine.each_process do |name, process|
      next if engine.formation[name] < 1
      write_template process_master_template, "#{app}-#{name}.conf", binding

      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        write_template process_template, "#{app}-#{name}-#{num}.conf", binding
      end
    end
  end

  private

  def master_template
    "upstart/master.conf.erb"
  end

  def process_master_template
    "upstart/process_master.conf.erb"
  end

  def process_template
    "upstart/process.conf.erb"
  end
end
