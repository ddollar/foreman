require "erb"
require "foreman/export"

class Foreman::Export::Bluepill < Foreman::Export::Base

  def export(location, options={})
    error("Must specify a location") unless location

    FileUtils.mkdir_p location

    app = self.app || File.basename(engine.directory)
    user = self.user || app
    log_root = self.log || "/var/log/#{app}"
    template_root = self.template

    Dir["#{location}/#{app}.pill"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    master_template = export_template("bluepill", "master.pill.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.pill", master_config
  end

end
