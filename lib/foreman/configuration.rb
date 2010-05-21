require "foreman"

class Foreman::Configuration

  attr_reader :app
  attr_reader :processes

  def initialize(app)
    @app = app
    @processes = {}
    read_initial_config
  end

  def scale(process, amount)
    old_amount = processes[process].to_i
    processes[process] = amount.to_i
    amount = amount.to_i

    if (old_amount < amount)
      ((old_amount + 1) .. amount).each { |num| system "start #{app}-#{process} NUM=#{num}" }
    elsif (amount < old_amount)
      ((amount + 1) .. old_amount).each { |num| system "stop #{app}-#{process} NUM=#{num}" }
    end

    write
  end

  def write
    write_file "/etc/foreman/#{app}.conf", <<-UPSTART_CONFIG
#{app}_processes="#{processes.keys.sort.join(' ')}"
#{processes.keys.sort.map { |k| "#{app}_#{k}=\"#{processes[k]}\"" }.join("\n")}
    UPSTART_CONFIG
  end

private ######################################################################

  def read_initial_config
    config = File.read("/etc/foreman/#{app}.conf").split("\n").inject({}) do |accum, line|
      key, value = line.match(/^(.+?)\s*=\s*"(.+?)"\s*$/).captures
      #accum.update(parts(1) => parts(2))
      accum.update(key => value)
    end
    config["#{app}_processes"].split(" ").each do |process|
      processes[process] = config["#{app}_#{process}"].to_i
    end
  rescue Errno::ENOENT
  end

  def write_file(filename, contents)
    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

end
