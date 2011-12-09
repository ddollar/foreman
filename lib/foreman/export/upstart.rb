require "erb"
require "foreman/export"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export(location, options={})
    error("Must specify a location") unless location

    FileUtils.mkdir_p location

    app = options[:app] || File.basename(engine.directory)
    user = options[:user] || app
    log_root = options[:log] || "/var/log/#{app}"
    template_root = options[:template]

    Dir["#{location}/#{app}*.conf"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    concurrency = Foreman::Utils.parse_concurrency(options[:concurrency])

    master_template = export_template("upstart", "master.conf.erb", template_root)
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.conf", master_config

    process_template = export_template("upstart", "process.conf.erb", template_root)

    engine.procfile.entries.each do |process|
      next if (conc = concurrency[process.name]) < 1
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

end
