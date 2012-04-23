file pkg("foreman-#{version}-jruby.gem") => distribution_files do |t|
  Bundler.with_clean_env do
    sh "env PLATFORM=java gem build foreman.gemspec"
  end
  sh "mv foreman-#{version}-java.gem #{t.name}"
end

task "jruby:build" => pkg("foreman-#{version}-jruby.gem")

task "jruby:clean" do
  clean pkg("foreman-#{version}-jruby.gem")
end

task "jruby:release" => "jruby:build" do |t|
  sh "gem push #{pkg("foreman-#{version}-jruby.gem")} || echo 'error'"
end
