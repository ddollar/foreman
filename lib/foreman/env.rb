require "foreman"

# Reads and exposes environment variables
# from a .env file.
class Foreman::Env
  def initialize(filename)
    @entries = File.read(filename).gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, ax|
      next unless line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
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
