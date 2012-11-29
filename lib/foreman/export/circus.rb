require "erb"
require "foreman/export"

class Foreman::Export::Circus < Foreman::Export::Base

  def export
    super

    Dir["#{location}/#{app}*.ini"].each do |file|
      clean file
    end

    write_template "circus/app.ini.erb", "#{app}.ini", binding
  end

end
