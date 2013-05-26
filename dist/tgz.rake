file pkg("foreman-#{version}.tgz") => distribution_files do |t|
  tempdir do |dir|
    mkchdir("foreman") do
      assemble_distribution
      assemble_gems
      rm_f "bin/foreman"
      assemble resource("tgz/foreman"), "bin/foreman", 0755
    end

    sh "tar czvf #{t.name} foreman"
  end
end

task "tgz:build" => pkg("foreman-#{version}.tgz")

task "tgz:clean" do
  clean pkg("foreman-#{version}.tgz")
end

task "tgz:release" => "tgz:build" do |t|
  store pkg("foreman-#{version}.tgz"), "foreman/foreman-#{version}.tgz"
  store pkg("foreman-#{version}.tgz"), "foreman/foreman-beta.tgz" if beta?
  store pkg("foreman-#{version}.tgz"), "foreman/foreman.tgz" unless beta?
end
