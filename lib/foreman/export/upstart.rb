require "erb"
require "foreman/export"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export(process_name=nil)
    Dir["#{location}/#{app}*.conf"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    master_template = export_template("upstart", "master.conf.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.conf", master_config

    if process_name
      export_process(engine.procfile[process_name])
    else
      engine.processes.each { |process| export_process(process) }
    end
  end
  
  private
  def export_process(process)
    process_template = export_template("upstart", "process.conf.erb", template_root)
    
    process_master_template = export_template("upstart", "process_master.conf.erb", template_root)
    process_master_config   = ERB.new(process_master_template).result(binding)
    write_file "#{location}/#{app}-#{process.name}.conf", process_master_config

    1.upto(concurrency[process.name]) do |num|
      port = engine.port_for(process, num, options[:port])
      process_config = ERB.new(process_template).result(binding)
      write_file "#{location}/#{app}-#{process.name}-#{num}.conf", process_config
    end
  end
end
