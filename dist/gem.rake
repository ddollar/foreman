file pkg("foreman-#{version}.gem") => distribution_files do |t|
  sh "gem build foreman.gemspec"
  sh "mv foreman-#{version}.gem #{t.name}"
end

task "gem:build" => pkg("foreman-#{version}.gem")

task "gem:clean" do
  clean pkg("foreman-#{version}.gem")
end

task "gem:release" => "gem:build" do |t|
  sh "gem push #{pkg("foreman-#{version}.gem")} || echo 'error'"
end
