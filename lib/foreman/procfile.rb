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

  def initialize(filename=nil)
    @entries = []
    load(filename) if filename
  end

  def [](name)
    entries.detect { |entry| entry.name == name }
  end

  def process_names
    entries.map(&:name)
  end

  def load(filename)
    entries.clear
    parse_procfile(filename)
  end

  def write(filename)
    File.open(filename, 'w') do |io|
      entries.each do |ent|
        io.puts(ent)
      end
    end
  end

  def <<(entry)
    entries << Foreman::ProcfileEntry.new(*entry)
    self
  end


protected

  def parse_procfile(filename)
    File.read(filename).split("\n").map do |line|
      if line =~ /^([A-Za-z0-9_]+):\s*(.+)$/
        self << [ $1, $2 ]
      end
    end.compact
  end

end
