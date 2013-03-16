require "erb"
require "foreman/export"

class Foreman::Export::Launchd < Foreman::Export::Base

  def export
    super
    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        command_args = process.command.split(" ")
        write_template "launchd/launchd.plist.erb", "#{app}-#{name}-#{num}.plist", binding
      end
    end
  end

end
