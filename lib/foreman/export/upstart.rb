require "erb"
require "foreman/export/base"

class Foreman::Export::Upstart < Foreman::Export::Base

  def export(location, options={})
    error("Must specify a location") unless location

    FileUtils.mkdir_p location

    app = options[:app] || File.basename(engine.directory)

    Dir["#{location}/#{app}*.conf"].each do |file|
      say "cleaning up: #{file}"
      FileUtils.rm(file)
    end

    concurrency = parse_concurrency(options[:concurrency])

    master_template = export_template("upstart/master.conf.erb")
    master_config   = ERB.new(master_template).result(binding)
    write_file "#{location}/#{app}.conf", master_config

    process_template = export_template("upstart/process.conf.erb")

    engine.processes.values.each do |process|
      1.upto(concurrency[process.name]) do |num|
        process_config = ERB.new(process_template).result(binding)
        write_file "#{location}/#{app}-#{process.name}-#{num}.conf", process_config
      end
    end
  end

end
