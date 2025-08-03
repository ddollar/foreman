require "foreman/version"

module Foreman

  def self.runner
    File.expand_path("../../bin/foreman-runner", __FILE__)
  end

  def self.ruby_18?
    defined?(RUBY_VERSION) and RUBY_VERSION =~ /^1\.8\.\d+/
  end

  def self.windows?
    Gem.win_platform?
  end

end
