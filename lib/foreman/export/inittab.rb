require "foreman/export"

class Foreman::Export::Inittab < Foreman::Export::Base

  def export(fname=nil, options={})
    app = options[:app] || File.basename(engine.directory)
    user = options[:user] || app
    log_root = options[:log] || "/var/log/#{app}"

    concurrency = Foreman::Utils.parse_concurrency(options[:concurrency])

    inittab = []
    inittab << "# ----- foreman #{app} processes -----"

    engine.procfile.entries.inject(1) do |index, process|
      1.upto(concurrency[process.name]) do |num|
        id = app.slice(0, 2).upcase + sprintf("%02d", index)
        port = engine.port_for(process, num, options[:port])
        inittab << "#{id}:4:respawn:/bin/su - #{user} -c 'PORT=#{port} #{process.command} >> #{log_root}/#{process.name}-#{num}.log 2>&1'"
        index += 1
      end
      index
    end

    inittab << "# ----- end foreman #{app} processes -----"

    inittab = inittab.join("\n") + "\n"

    if fname
      FileUtils.mkdir_p(log_root) rescue error "could not create #{log_root}"
      FileUtils.chown(user, nil, log_root) rescue error "could not chown #{log_root} to #{user}"
      write_file(fname, inittab)
    else
      puts inittab
    end
  end

end
