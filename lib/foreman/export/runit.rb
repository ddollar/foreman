require "erb"
require "foreman/export"

class Foreman::Export::Runit < Foreman::Export::Base
  ENV_VARIABLE_REGEX = /([a-zA-Z_]+[a-zA-Z0-9_]*)=(\S+)/

  def export(location, options={})
    error("Must specify a location") unless location

    app = self.app || File.basename(engine.directory)
    user = self.user || app
    log_root = self.log || "/var/log/#{app}"
    template_root = self.template

    run_template = export_template('runit', 'run.erb', template_root)
    log_run_template = export_template('runit', 'log_run.erb', template_root)

    engine.procfile.entries.each do |process|
      1.upto(self.concurrency[process.name]) do |num|
        process_directory     = "#{location}/#{app}-#{process.name}-#{num}"
        process_env_directory = "#{process_directory}/env"
        process_log_directory = "#{process_directory}/log"

        create_directory process_directory
        create_directory process_env_directory
        create_directory process_log_directory

        run = ERB.new(run_template).result(binding)
        write_file "#{process_directory}/run", run
        FileUtils.chmod 0755, "#{process_directory}/run"

        port = engine.port_for(process, num, self.port)
        environment_variables = {'PORT' => port}.
            merge(engine.environment).
            merge(inline_variables(process.command))

        environment_variables.each_pair do |var, env|
          write_file "#{process_env_directory}/#{var.upcase}", env
        end

        log_run = ERB.new(log_run_template).result(binding)
        write_file "#{process_log_directory}/run", log_run
        FileUtils.chmod 0755, "#{process_log_directory}/run"
      end
    end

  end

  private
  def create_directory(location)
    say "creating: #{location}"
    FileUtils.mkdir_p(location)
  end

  def inline_variables(command)
    variable_name_regex =
    Hash[*command.scan(ENV_VARIABLE_REGEX).flatten]
  end
end
