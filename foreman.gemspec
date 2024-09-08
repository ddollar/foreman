$:.unshift File.expand_path("lib", __dir__)
require "foreman/version"

Gem::Specification.new do |gem|
  gem.name = "foreman"
  gem.license = "MIT"
  gem.version = Foreman::VERSION

  gem.author = "Jane Davis"
  gem.summary = "Process manager for applications with multiple components"

  gem.description = gem.summary

  gem.executables = "foreman"
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.files << "man/foreman.1"
end
