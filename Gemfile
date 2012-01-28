source "http://rubygems.org"

gemspec

platform :mingw do
  gem "win32console", "~> 1.3.0"
end

platform :jruby do
  gem "posix-spawn", "~> 0.3.6"
end

platform :ruby_19 do
  gem "simplecov"
end

group :development do
  gem 'parka'
  gem 'rake'
  gem 'ronn'
  gem 'fakefs', '~> 0.3.2'
  gem 'rcov',   '~> 0.9.8'
  gem 'rr',     '~> 1.0.2'
  gem 'rspec',  '~> 2.0'
  gem 'ZenTest'
  gem 'aws-s3'
  gem "rubyzip"
end
