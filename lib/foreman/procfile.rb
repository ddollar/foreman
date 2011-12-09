require "foreman"
require "foreman/procfile_entry"

# A valid Procfile entry is captured by this regex.
# All other lines are ignored.
#
# /^([A-Za-z0-9_]+):\s*(.+)$/
#
# $1 = name
# $2 = command
#
class Foreman::Procfile

  attr_reader :entries

  def initialize(filename)
    @entries = parse_procfile(filename)
  end

  def [](name)
    entries.detect { |entry| entry.name == name }
  end

  def process_names
    entries.map(&:name)
  end

private

  def parse_procfile(filename)
    File.read(filename).split("\n").map do |line|
      if line =~ /^([A-Za-z0-9_]+):\s*(.+)$/
        Foreman::ProcfileEntry.new($1, $2)
      end
    end.compact
  end

end
