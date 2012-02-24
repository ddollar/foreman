require "time"

desc "Build the manual"
task :man do
  ENV['RONN_MANUAL']  = "Foreman Manual"
  ENV['RONN_ORGANIZATION'] = "Foreman #{Foreman::VERSION}"
  sh "ronn -w -s toc -r5 --markdown man/*.ronn"
end

desc "Commit the manual to git"
task "man:commit" => :man do
  sh "git add README.md"
  sh "git commit -am 'update docs' || echo 'nothing to commit'"
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

def latest_release
  latest = File.read("Changelog.md").split("\n").first.split(" ")[1]
end

def newer_release
  tags = %x{ git tag --contains v#{latest_release} }.split("\n").sort_by do |tag|
    Gem::Version.new(tag[1..-1])
  end
  tags.reject { |tag| Gem::Version.new(tag[1..-1]).prerelease? }[1]
end

desc "Generate a Changelog"
task :changelog do
  while release = newer_release
    entry = %x{ git show --format="%cd" #{release} | head -n 1 }
    date = Time.parse(entry.chomp).strftime("%Y-%m-%d")

    message  = "## #{release[1..-1]} (#{date})\n\n"
    message += %x{ git log --format="* %s  [%an]" v#{latest_release}..#{release} }

    changelog = File.read("Changelog.md")
    changelog = message + "\n" + changelog

    puts release

    File.open("Changelog.md", "w") do |file|
      file.print changelog
    end
  end
end

desc "Cut a release"
task :release do
  Rake::Task["authors"].invoke
  Rake::Task["changelog"].invoke
  Rake::Task["pages"].invoke
end
