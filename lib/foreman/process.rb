require "foreman"

class Foreman::Process

  attr_reader :name
  attr_reader :command
  attr_accessor :color

  def initialize(name, command)
    @name    = name
    @command = command
  end

end
