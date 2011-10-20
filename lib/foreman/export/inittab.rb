require "foreman/export"

class Foreman::Export::Inittab < Foreman::Export::Base

  def export(process_name=nil)    
    processes = process_name ? [engine.procfile[process_name]] : engine.processes
    
    master_template = export_template("inittab", "master.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    master_config   = master_config.gsub(/\n{2,}/, "\n")
    
    write_file("#{location}/#{app}", master_config)
  end
end
