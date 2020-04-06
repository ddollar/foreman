$:.unshift File.expand_path("../lib", __FILE__)
require "foreman/version"

Gem::Specification.new do |gem|
  gem.name     = "foreman"
  gem.license  = "MIT"
  gem.version  = Foreman::VERSION

  gem.author   = "David Dollar"
  gem.email    = "ddollar@gmail.com"
  gem.homepage = "https://github.com/ddollar/foreman"
  gem.summary  = "Process manager for applications with multiple components"

  gem.description = gem.summary

  gem.metadata = {
    "bug_tracker_uri" => "#{gem.homepage}/issues",
    "changelog_uri" => "#{gem.homepage}/blob/master/Changelog.md",
    "documentation_uri" => "https://ddollar.github.io/foreman/",
    "homepage_uri" => gem.homepage,
    "source_code_uri" => "#{gem.homepage}/tree/v#{gem.version}",
    "wiki_uri" => "#{gem.homepage}/wiki"
  }

  gem.executables = "foreman"
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.files << "man/foreman.1"
end
