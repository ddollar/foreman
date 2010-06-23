require "rake"
require "rspec"
require "rspec/core/rake_task"

$:.unshift File.expand_path("../lib", __FILE__)
require "foreman"

task :default => :spec
task :release => :man

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

desc 'Build the manual'
task :man do
  ENV['RONN_MANUAL']  = "Foreman Manual"
  ENV['RONN_ORGANIZATION'] = "Foreman #{Foreman::VERSION}"
  sh "ronn -w -s toc -r5 --markdown man/*.ronn"
  sh "cp man/foreman.1.markdown README.markdown"
  sh "git add README.markdown"
  sh "git commit -m 'update readme' || echo 'nothing to commit'"
end

task :pages => :man do
  sh %{
    cp man/foreman.1.html /tmp/foreman.1.html
    git checkout gh-pages
    rm ./index.html
    cp /tmp/foreman.1.html ./index.html
    git add -u index.html
    git commit -m "rebuilding man page"
    git push origin -f gh-pages
    git checkout master
  }
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

    s.files = %w(Rakefile README.md) + Dir["{bin,export,lib,spec}/**/*"]
    s.require_path = "lib"

    # #s.bindir             = "bin"
    # s.executables        = Dir["bin/*"]
    s.default_executable = "foreman"

    s.add_development_dependency 'fakefs', '~> 0.2.1'
    s.add_development_dependency 'rake',   '~> 0.8.7'
    s.add_development_dependency 'rcov',   '~> 0.9.8'
    s.add_development_dependency 'rr',     '~> 0.10.11'
    s.add_development_dependency 'rspec',  '~> 2.0.0'

    s.add_dependency 'term-ansicolor', '~> 1.0.5'
    s.add_dependency 'thor', '~> 0.13.6'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
