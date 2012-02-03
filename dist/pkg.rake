require "erb"

file pkg("foreman-#{version}.pkg") => distribution_files do |t|
  tempdir do |dir|
    mkchdir("foreman") do
      assemble_distribution
      assemble_gems
      assemble resource("pkg/foreman"), "bin/foreman", 0755
    end

    kbytes = %x{ du -ks foreman | cut -f 1 }
    num_files = %x{ find foreman | wc -l }

    mkdir_p "pkg"
    mkdir_p "pkg/Resources"
    mkdir_p "pkg/foreman.pkg"

    dist = File.read(resource("pkg/Distribution.erb"))
    dist = ERB.new(dist).result(binding)
    File.open("pkg/Distribution", "w") { |f| f.puts dist }

    dist = File.read(resource("pkg/PackageInfo.erb"))
    dist = ERB.new(dist).result(binding)
    File.open("pkg/foreman.pkg/PackageInfo", "w") { |f| f.puts dist }

    mkdir_p "pkg/foreman.pkg/Scripts"
    cp resource("pkg/postinstall"), "pkg/foreman.pkg/Scripts/postinstall"
    chmod 0755, "pkg/foreman.pkg/Scripts/postinstall"

    sh %{ mkbom -s foreman pkg/foreman.pkg/Bom }

    Dir.chdir("foreman") do
      sh %{ pax -wz -x cpio . > ../pkg/foreman.pkg/Payload }
    end

    sh %{ pkgutil --flatten pkg foreman-#{version}.pkg }

    FileUtils.mkdir_p(File.dirname(t.name))
    cp_r "foreman-#{version}.pkg", t.name
  end
end

task "pkg:build" => pkg("foreman-#{version}.pkg")

task "pkg:clean" do
  clean pkg("foreman-#{version}.pkg")
end

task "pkg:release" => "pkg:build" do |t|
  store pkg("foreman-#{version}.pkg"), "foreman/foreman-#{version}.pkg"
  store pkg("foreman-#{version}.pkg"), "foreman/foreman-beta.pkg" if beta?
  store pkg("foreman-#{version}.pkg"), "foreman/foreman.pkg" unless beta?
end
