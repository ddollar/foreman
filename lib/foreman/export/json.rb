require "foreman/export/base"
require "json"

class Foreman::Export::JSON < Foreman::Export::Base

  def export(fname=nil, options={})
    processes = engine.processes.values.inject({}) do |hash, process|
      hash.update(process.name => { "command" => process.command })
    end
    puts processes.to_json
  end

end
