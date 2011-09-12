$:.unshift File.expand_path("../lib", __FILE__)
require "foreman/version"

Gem::Specification.new do |gem|
  gem.name     = "foreman"
  gem.version  = Foreman::VERSION

  gem.author   = "David Dollar"
  gem.email    = "ddollar@gmail.com"
  gem.homepage = "http://github.com/ddollar/foreman"
  gem.summary  = "Process manager for applications with multiple components"

  gem.description = gem.summary

  gem.executables = "foreman"
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.files << "man/foreman.1"

  gem.add_dependency 'term-ansicolor', '~> 1.0.5'
  gem.add_dependency 'thor',           '>= 0.13.6'
end
