require "foreman"

# A valid Procfile entry is captured by this regex.
# All other lines are ignored.
#
# /^([A-Za-z0-9_]+):\s*(.+)$/
#
# $1 = name
# $2 = command
#
class Foreman::Procfile

  attr_reader :processes

  def initialize(filename)
    @processes = parse_procfile(filename)
  end

  def process_names
    processes.map(&:name)
  end

  def [](name)
    processes.detect { |process| process.name == name }
  end

private

  def parse_procfile(filename)
    File.read(filename).split("\n").map do |line|
      if line =~ /^([A-Za-z0-9_]+):\s*(.+)$/
        Foreman::Process.new($1, $2)
      end
    end.compact
  end

end
