require "erb"
require "foreman/export"

class Foreman::Export::Launchd < Foreman::Export::Base

  def export
    super
    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        write_template "launchd/launchd.plist.erb", "#{app}-#{name}-#{num}.plist", binding
      end
    end
  end

end
