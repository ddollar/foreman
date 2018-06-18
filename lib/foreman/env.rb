require "foreman"

# Reads and exposes environment variables
# from a .env file.
class Foreman::Env
  LINE = /
    \A
    \s*
    (?:export\s+)?    # optional export
    ([\w\.]+)         # key
    (?:\s*=\s*|:\s+?) # separator
    (                 # optional value begin
      '(?:\'|[^'])*'  #   single quoted value
      |               #   or
      "(?:\"|[^"])*"  #   double quoted value
      |               #   or
      [^#\n]+         #   unquoted value
    )?                # value end
    \s*
    (?:\#.*)?         # optional comment
    \z
  /x

  def initialize(filename)
    @entries = File.read(filename).gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, ax|
      next unless line =~ LINE
      key = Regexp.last_match(1)
      ax[key] =
        case val = Regexp.last_match(2)
          # Remove single quotes
        when /\A'(.*)'\z/ then Regexp.last_match(1)
          # Remove double quotes and unescape string preserving newline characters
        when /\A"(.*)"\z/ then Regexp.last_match(1).gsub('\n', "\n").gsub(/\\(.)/, '\1')
        else val
        end
    end
  end

  def entries
    @entries.each do |key, value|
      yield key, value
    end
  end
end
