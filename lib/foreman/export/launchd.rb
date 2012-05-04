require "erb"
require "foreman/export"

class Foreman::Export::Launchd < Foreman::Export::Base

  def export
    error("Must specify a location") unless location
    
    app = self.app || File.basename(engine.directory)
    user = self.user || app
    log_root = self.log || "/var/log/#{app}"
    template_root = self.template
    
    FileUtils.mkdir_p(location)
    
    engine.procfile.entries.each do |process|
      1.upto(self.concurrency[process.name]) do |num|

        master_template = export_template("launchd", "launchd.plist.erb", template_root)
        master_config   = ERB.new(master_template).result(binding)
        write_file "#{location}/#{app}-#{process.name}-#{num}.plist", master_config
      end
    end
    
  end

end
