# coding: utf-8
require "erb"
require "foreman/export"

class Foreman::Export::Initscript < Foreman::Export::Base

  def export
    super
    clean File.join(location, app)
    write_template("initscript/master.erb", "#{app}", binding)
   end

end

