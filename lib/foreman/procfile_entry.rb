require "foreman"

class Foreman::ProcfileEntry

  attr_reader :name
  attr_reader :command
  attr_accessor :color

  def initialize(name, command)
    @name = name
    @command = command
  end

  def spawn(num, pipe, basedir, environment, base_port)
    (1..num).to_a.map do |n|
      process = Foreman::Process.new(self, n, base_port + (n-1))
      process.run(pipe, basedir, environment)
      process
    end
  end

end
