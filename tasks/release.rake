require "time"

desc "Build the manual"
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

desc "Generate an authors list"
task :authors do
  authors = %x{ git log --pretty=format:"%an" | sort -u }.split("\n")
  puts authors.join(", ")
end

def latest_release
  latest = File.read("Changelog.md").split("\n").first.split(" ").last
end

def newer_release
  tags = %x{ git tag --contains #{latest_release} }.split("\n").sort_by do |tag|
    Gem::Version.new(tag[1..-1])
  end
  tags.reject { |tag| Gem::Version.new(tag[1..-1]).prerelease? }[1]
end

desc "Generate a Changelog"
task :changelog do
  while release = newer_release
    entry = %x{ git show --format="%h %cd" #{release} | head -n 1 }
    commit, date_raw = entry.split(" ", 2)
    date = Time.parse(date_raw).strftime("%Y-%m-%d")

    message  = "## #{release[1..-1]} #{date} #{commit}\n\n"
    message += %x{ git log --format="* %s  [%an]" #{latest_release}..#{release} }

    changelog = File.read("Changelog.md")
    changelog = message + "\n" + changelog

    puts release

    File.open("Changelog.md", "w") do |file|
      file.puts changelog
    end
  end
    

  #   date = 
  #   message = "## #{release[1..-1]} 
  # timestamp = Time.now.utc.strftime('%m/%d/%Y')
  # sha = `git log | head -1`.split(' ').last
  # changelog = ["#{version} #{timestamp} #{sha}"]
  # changelog << ('=' * changelog[0].length)
  # changelog << ''

  # last_sha = `cat Changelog | head -1`.split(' ').last
  # shortlog = `git log #{last_sha}..HEAD --pretty=format:'%s   [%an]'`
  # changelog << shortlog.split("\n")
  # changelog.concat ['', '', '']

  # old_changelog = File.read('Changelog')
  # File.open('Changelog', 'w') do |file|
  #   file.write(changelog.join("\n"))
  #   file.write(old_changelog)
  # end
end
