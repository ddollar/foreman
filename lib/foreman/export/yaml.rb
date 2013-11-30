require "foreman/export"
require "yaml"

class Foreman::Export::Yaml < Foreman::Export::Base

  def export
    super
    clean "#{location}/#{app}.yml"
    write_template "yaml/app.yml.erb", "#{app}.yml", binding
  end

end
