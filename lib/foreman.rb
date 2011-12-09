require "foreman/version"

module Foreman

  class AppDoesNotExist < Exception; end

  # load contents of env_file into ENV
  def self.load_env!(env_file = './.env')
    require 'foreman/engine'
    Foreman::Engine.load_env!(env_file)
  end

  def self.runner
    File.expand_path("../../bin/runner", __FILE__)
  end

end

