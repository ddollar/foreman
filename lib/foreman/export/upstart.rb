require "foreman/export"

class Foreman::Export::Upstart

  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end

  def export(name)
    FileUtils.mkdir_p "/etc/foreman"
    FileUtils.mkdir_p "/etc/init"

    write_file "/etc/foreman/#{name}.conf", <<-UPSTART_CONFIG
#{name}_processes="#{engine.processes.keys.join(' ')}"
#{engine.processes.keys.map { |k| "#{name}_#{k}=\"1\"" }.join("\n")}
    UPSTART_CONFIG

    write_file "/etc/init/#{name}.conf", <<-UPSTART_MASTER
pre-start script

bash << "EOF"
  mkdir -p /var/log/#{name}

  if [ -f /etc/foreman/#{name}.conf ]; then
    source /etc/foreman/#{name}.conf
  fi

  for process in $( echo "$#{name}_processes" ); do
    process_count_config="#{name}_$process"
    process_count=${!process_count_config}

    for ((i=1; i<=${process_count:=1}; i+=1)); do
      start #{name}-$process NUM=$i
    done
  done
EOF

end script
    UPSTART_MASTER

    engine.processes.values.each do |process|
      write_file "/etc/init/#{name}-#{process.name}.conf", <<-UPSTART_CHILD
instance $NUM
stop on stopping #{name}
respawn

chdir #{engine.directory}
exec #{process.command} 2>&1 > /var/log/#{name}/#{process.name}.log
      UPSTART_CHILD
    end
  end

private

  def write_file(filename, contents)
    File.open(filename, "w") do |file|
      file.puts contents
    end
  end

end
