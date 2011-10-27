require "erb"
require "foreman/export"

class Foreman::Export::Bluepill < Foreman::Export::Base

  def export(process_name=nil)
    Dir["#{location}/#{app}.pill"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end
    
    processes = process_name ? [engine.procfile[process_name]] : engine.processes
    
    master_template = export_template("bluepill", "master.pill.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    master_config   = master_config.gsub(/\n{3,}/, "\n\n")
    
    write_file("#{location}/#{app}.pill", master_config)
  end

end
