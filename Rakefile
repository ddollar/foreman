require "rubygems"
require "rake"
require "rspec/core/rake_task"

$:.unshift File.expand_path("../lib", __FILE__)
require "foreman"

task :default => :spec

desc "Run all specs"
Rspec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Generate RCov code coverage report"
task :rcov => "rcov:build" do
  %x{ open coverage/index.html }
end

Rspec::Core::RakeTask.new("rcov:build") do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = [ "--exclude", Gem.default_dir , "--exclude", "spec" ]
end

######################################################

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name    = "foreman"
    s.version = Foreman::VERSION

    s.summary     = "Process manager for applications with multiple components"
    s.description = s.summary
    s.author      = "David Dollar"
    s.email       = "ddollar@gmail.com"
    s.homepage    = "http://github.com/ddollar/foreman"

    s.platform = Gem::Platform::RUBY
    s.has_rdoc = false

    s.files = %w(Rakefile README.md) + Dir["{bin,lib,spec}/**/*"]
    s.require_path = "lib"

    s.bindir             = "bin"
    s.executables        = Dir["bin/*"]
    s.default_executable = "foreman"

    s.add_development_dependency 'fakefs', '~> 0.2.1'
    s.add_development_dependency 'rake',   '~> 0.8.7'
    s.add_development_dependency 'rcov',   '~> 0.9.8'
    s.add_development_dependency 'rr',     '~> 0.10.11'
    s.add_development_dependency 'rspec',  '~> 2.0.0'

    s.add_dependency 'thor', '~> 0.13.6'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
