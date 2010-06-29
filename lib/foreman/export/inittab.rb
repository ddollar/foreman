require "foreman/export/base"

class Foreman::Export::Inittab < Foreman::Export::Base

  def export(fname=nil, options={})
    app = options[:app] || File.basename(engine.directory)
    user = options[:user] || app
    log_root = options[:log] || "/var/log"

    concurrency = parse_concurrency(options[:concurrency])

    inittab = []
    inittab << "# ----- foreman #{app} processes -----"
    engine.processes.values.each_with_index do |process, num|
      id = app.slice(0, 2).upcase + sprintf("%02d", num+1)
      inittab << "#{id}:4:respawn:/bin/su - #{user} -c '#{process.command} >> #{log_root}/#{process.name}-#{num+1}.log 2>&1'"
    end
    inittab << "# ----- end foreman #{app} processes -----"

    inittab = inittab.join("\n") + "\n"

    if fname
      FileUtils.mkdir_p(log_root)
      FileUtils.chown(user, nil, log_root)
      write_file(fname, inittab)
    else
      puts inittab
    end
  end

end
