require "rubygems"
require "parka/specification"

Parka::Specification.new do |gem|
  gem.name     = "foreman"
  gem.version  = Foreman::VERSION
  gem.summary  = "Process manager for applications with multiple components"
  gem.homepage = "http://github.com/ddollar/foreman"

  gem.executables  = "foreman"
  gem.files       << "man/foreman.1"
end
