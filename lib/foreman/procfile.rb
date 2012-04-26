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

  def initialize(filename_or_entries)
    @entries = filename_or_entries.is_a?(Array) ? filename_or_entries : parse_procfile(filename_or_entries)
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
