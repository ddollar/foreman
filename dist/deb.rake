file pkg("/apt-#{version}/foreman-#{version}.deb") => distribution_files("deb") do |t|
  mkchdir(File.dirname(t.name)) do
    mkchdir("usr/local/foreman") do
      assemble_distribution
      assemble_gems
      assemble resource("deb/foreman"), "bin/foreman", 0755
      File.chmod 0755, "bin/foreman-runner"
    end

    assemble resource("deb/control"), "control"
    assemble resource("deb/postinst"), "postinst"

    sh "tar czvf data.tar.gz usr/local/foreman --owner=root --group=root"
    sh "tar czvf control.tar.gz control postinst"

    File.open("debian-binary", "w") do |f|
      f.puts "2.0"
    end

    deb = File.basename(t.name)

    sh "ar -r #{t.name} debian-binary control.tar.gz data.tar.gz"
  end
end

desc "Build a .deb package"
task "deb:build" => pkg("/apt-#{version}/foreman-#{version}.deb")

desc "Remove build artifacts for .deb"
task "deb:clean" do
  clean pkg("foreman-#{version}.deb")
  FileUtils.rm_rf("pkg/apt-#{version}") if Dir.exists?("pkg/apt-#{version}")
end
