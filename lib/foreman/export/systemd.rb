require "erb"
require "foreman/export"

class Foreman::Export::Systemd < Foreman::Export::Base

  def export
    super

    Dir["#{location}/#{app}*.target"]
      .concat(Dir["#{location}/#{app}*.service"])
      .concat(Dir["#{location}/#{app}*.target.wants/#{app}*.service"])
      .each do |file|
      clean file
    end

    Dir["#{location}/#{app}*.target.wants"].each do |file|
      clean_dir file
    end

    process_master_names = []

    engine.each_process do |name, process|
      service_fn = "#{app}-#{name}@.service"
      write_template "systemd/process.service.erb", service_fn, binding

      create_directory("#{app}-#{name}.target.wants")
      1.upto(engine.formation[name])
        .collect { |num| engine.port_for(process, num) }
        .collect { |port| "#{app}-#{name}@#{port}.service" }
        .each do |process_name|
        create_symlink("#{app}-#{name}.target.wants/#{process_name}", "../#{service_fn}") rescue Errno::EEXIST # This is needed because rr-mocks do not call the origial cleanup
      end

      write_template "systemd/process_master.target.erb", "#{app}-#{name}.target", binding
      process_master_names << "#{app}-#{name}.target"
    end

    write_template "systemd/master.target.erb", "#{app}.target", binding
  end
end
