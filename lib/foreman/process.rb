require "foreman"

class Foreman::Process

  attr_reader :name
  attr_reader :command
  attr_reader :concurrency
  attr_accessor :color

  def initialize(name, command, concurrency)
    @name    = name
    @command = command
    @concurrency = concurrency
  end

end
