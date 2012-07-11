file pkg("foreman-#{version}-x86-mswin32.gem") => distribution_files do |t|
  Bundler.with_clean_env do
    sh "env PLATFORM=mswin32 gem build foreman.gemspec"
  end
  sh "mv foreman-#{version}-x86-mswin32.gem #{t.name}"
end

task "mswin32:build" => pkg("foreman-#{version}-x86-mswin32.gem")

task "mswin32:clean" do
  clean pkg("foreman-#{version}-x86-mswin32.gem")
end

task "mswin32:release" => "mswin32:build" do |t|
  sh "gem push #{pkg("foreman-#{version}-x86-mswin32.gem")} || echo 'error'"
end
