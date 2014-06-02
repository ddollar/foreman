source "http://rubygems.org"

gemspec

platform :mingw do
  gem "win32console", "~> 1.3.0"
end

group :test do
  gem 'rake'
  gem 'fakefs', '~> 0.3.2'
  gem 'rr',     '~> 1.0.2'
  gem 'rspec',  '~> 2.14.0'
  gem "simplecov", :require => false
  gem 'timecop'
  gem "codeclimate-test-reporter", :require => false
end

group :development do
  gem 'aws-s3'
  gem 'ronn'
  gem 'yard'
end
