require "erb"
require "foreman/export"

class Foreman::Export::Supervisord < Foreman::Export::Base

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

    app_template = export_template("supervisord", "app.conf.erb", template_root)
    app_config   = ERB.new(app_template, 0, '<').result(binding)
    write_file "#{location}/#{app}.conf", app_config
  end

  def wrap_environment env
    if env.index(',').nil?
      env
    else
      "\"#{env}\""
    end
  end

end
