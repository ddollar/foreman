require "erb"
require "foreman/export"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export
    error("Must specify a location") unless location

    FileUtils.mkdir_p location

    app = self.app || File.basename(engine.directory)
    user = self.user || app
    log_root = self.log || "/var/log/#{app}"
    template_root = self.template

    Dir["#{location}/#{app}*.conf"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    master_template = export_template("upstart", "master.conf.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.conf", master_config

    process_template = export_template("upstart", "process.conf.erb", template_root)

    engine.procfile.entries.each do |process|
      next if (conc = self.concurrency[process.name]) < 1
      process_master_template = export_template("upstart", "process_master.conf.erb", template_root)
      process_master_config   = ERB.new(process_master_template).result(binding)
      write_file "#{location}/#{app}-#{process.name}.conf", process_master_config

      1.upto(self.concurrency[process.name]) do |num|
        port = engine.port_for(process, num, self.port)
        process_config = ERB.new(process_template).result(binding)
        write_file "#{location}/#{app}-#{process.name}-#{num}.conf", process_config
      end
    end
  end

end
