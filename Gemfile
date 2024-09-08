source "http://rubygems.org"

gemspec

group :test do
  gem "fakefs"
  gem "rspec", "~> 3.5"
  gem "simplecov", require: false
  gem "timecop"
end

group :development do
  gem "aws-s3"
  gem "ronn-ng"
  gem "yard", "~> 0.9.11"
  gem "automatiek"
end


gem "thor", "~> 1.3"

gem "rake", "~> 13.2", :groups => [:development, :test]
gem "peppermint", "~> 0.1.14", :groups => [:development, :test]
