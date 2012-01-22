file pkg("foreman-#{version}-jruby.gem") => distribution_files do |t|
  sh "env JRUBY=true gem build foreman.gemspec"
  sh "mv foreman-#{version}.gem #{t.name}"
end

task "jruby:build" => pkg("foreman-#{version}-jruby.gem")

task "jruby:clean" do
  clean pkg("foreman-#{version}-jruby.gem")
end

task "jruby:release" => "jruby:build" do |t|
  sh "parka push -f #{pkg("foreman-#{version}-jruby.gem")}"
end
