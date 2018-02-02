require "foreman"
require "dotenv"

class Foreman::Env

  attr_reader :entries

  def initialize(filename)
    @entries = Dotenv::Parser.call(File.read(filename))
  end

  def entries
    @entries.each do |key, value|
      yield key, value
    end
  end

end
