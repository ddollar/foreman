require "erb"
require "foreman/export"

class Foreman::Export::Launchd < Foreman::Export::Base

  def export
    super
    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        environment = engine.env.dup
        process.ports.each_with_index { |port, index|
          environment[port] = engine.port_for(process, num, index).to_s
        }
        command_args = process.command.split(" ")
        write_template "launchd/launchd.plist.erb", "#{app}-#{name}-#{num}.plist", binding
      end
    end
  end

end
