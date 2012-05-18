require "foreman/version"

module Foreman

  class AppDoesNotExist < Exception; end

  def self.jruby?
    defined?(RUBY_PLATFORM) and RUBY_PLATFORM == "java"
  end

  def self.windows?
    defined?(RUBY_PLATFORM) and RUBY_PLATFORM =~ /(win|w)32$/
  end

end
