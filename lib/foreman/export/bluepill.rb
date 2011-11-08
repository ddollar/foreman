require "erb"
require "foreman/export"

class Foreman::Export::Bluepill < Foreman::Export::Base

  def export(location, options={})
    error("Must specify a location") unless location

    FileUtils.mkdir_p location

    app = options[:app] || File.basename(engine.directory)
    user = options[:user] || app
    log_root = options[:log] || "/var/log/#{app}"
    template_root = options[:template]

    Dir["#{location}/#{app}.pill"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    concurrency = Foreman::Utils.parse_concurrency(options[:concurrency])

    master_template = export_template("bluepill", "master.pill.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.pill", master_config
  end

end
