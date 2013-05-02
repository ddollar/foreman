source "http://rubygems.org"

gemspec

platform :mingw do
  gem "win32console", "~> 1.3.0"
end

platform :jruby, :ruby_18 do
  gem "posix-spawn", "~> 0.3.6"
end

group :development do
  gem 'aws-s3'
  gem 'rake'
  gem 'ronn'
  gem 'fakefs', '~> 0.3.2'
  gem 'rr',     '~> 1.0.2'
  gem 'rspec',  '~> 2.0'
  gem "simplecov", :require => false
  gem 'timecop'
  gem 'yard'
end
