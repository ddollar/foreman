require "erb"
require "foreman/export"

class Foreman::Export::Smf < Foreman::Export::Base

  def export
    super
    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        port = engine.port_for(process, num)
        write_template "smf/app.xml.erb", "#{app}-#{name}-#{num}.xml", binding
      end
    end
  end

end
