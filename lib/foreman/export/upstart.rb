require "erb"
require "foreman/export"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export
    super

    master_file = "#{app}.conf"

    clean master_file
    write_template master_template, master_file, binding

    engine.each_process do |name, process|
      process_master_file = "#{app}-#{name}.conf"
      clean process_master_file

      next if engine.formation[name] < 1
      write_template process_master_template, process_master_file, binding

      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        process_file = "#{app}-#{name}-#{num}.conf"
        clean process_file
        write_template process_template, process_file, binding
      end
    end
  end

  private

  def clean(file_name)
    path = File.expand_path(File.join(location, file_name))
    super path
  end

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
