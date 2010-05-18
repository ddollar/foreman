require "foreman/configuration"
require "foreman/export"

class Foreman::Export::Upstart

  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end

  def export(app)
    FileUtils.mkdir_p "/etc/foreman"
    FileUtils.mkdir_p "/etc/init"

    config = Foreman::Configuration.new(app)

    engine.processes.each do |name, process|
      config.scale(name, 1)
    end
    config.write

    write_file "/etc/init/#{app}.conf", <<-UPSTART_MASTER
pre-start script

bash << "EOF"
  mkdir -p /var/log/#{app}

  if [ -f /etc/foreman/#{app}.conf ]; then
    source /etc/foreman/#{app}.conf
  fi

  for process in $( echo "$#{app}_processes" ); do
    process_count_config="#{app}_$process"
    process_count=${!process_count_config}

    for ((i=1; i<=${process_count:=1}; i+=1)); do
      start #{app}-$process NUM=$i
    done
  done
EOF

end script
    UPSTART_MASTER

    engine.processes.values.each do |process|
      write_file "/etc/init/#{app}-#{process.name}.conf", <<-UPSTART_CHILD
instance $NUM
stop on stopping #{app}
respawn

chdir #{engine.directory}
exec #{process.command} >>/var/log/#{app}/#{process.name}.log 2>&1
      UPSTART_CHILD
    end
  end

private ######################################################################

  def write_file(filename, contents)
    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

end
