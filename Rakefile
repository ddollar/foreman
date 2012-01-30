$:.unshift File.expand_path("../lib", __FILE__)
require "foreman"

require "bundler/setup"

Dir[File.expand_path("../tasks/*.rake", __FILE__)].each do |task|
  load task
end
