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

desc "Generate a Changelog"
task :changelog do
  timestamp = Time.now.utc.strftime('%m/%d/%Y')
  sha = `git log | head -1`.split(' ').last
  changelog = ["#{version} #{timestamp} #{sha}"]
  changelog << ('=' * changelog[0].length)
  changelog << ''

  last_sha = `cat Changelog | head -1`.split(' ').last
  shortlog = `git log #{last_sha}..HEAD --pretty=format:'%s   [%an]'`
  changelog << shortlog.split("\n")
  changelog.concat ['', '', '']

  old_changelog = File.read('Changelog')
  File.open('Changelog', 'w') do |file|
    file.write(changelog.join("\n"))
    file.write(old_changelog)
  end
end
