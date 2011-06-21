require "rubygems"
require "bundler"
Bundler.setup

require "rake"
require "rspec"
require "rspec/core/rake_task"

$:.unshift File.expand_path("../lib", __FILE__)
require "foreman"

task :default => :spec
task :release => :man

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Generate RCov code coverage report"
task :rcov => "rcov:build" do
  %x{ open coverage/index.html }
end

RSpec::Core::RakeTask.new("rcov:build") do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = [ "--exclude", ".bundle", "--exclude", "spec" ]
end

desc 'Build the manual'
task :man do
  ENV['RONN_MANUAL']  = "Foreman Manual"
  ENV['RONN_ORGANIZATION'] = "Foreman #{Foreman::VERSION}"
  sh "ronn -w -s toc -r5 --markdown man/*.ronn"
end

desc "Commit the manual to git"
task "man:commit" => :man do
  sh "git add README.markdown"
  sh "git commit -m 'update readme' || echo 'nothing to commit'"
end

desc "Generate the Github docs"
task :pages => "man:commit" do
  sh %{
    cp man/foreman.1.html /tmp/foreman.1.html
    git checkout gh-pages
    rm ./index.html
    cp /tmp/foreman.1.html ./index.html
    git add -u index.html
    git commit -m "saving man page to github docs"
    git push origin -f gh-pages
    git checkout master
  }
end
