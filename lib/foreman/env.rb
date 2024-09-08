require "foreman"

class Foreman::Env
  attr_reader :entries

  def initialize(filename)
    @entries = File.read(filename).gsub("\r\n", "\n").split("\n").each_with_object({}) do |line, ax|
      if line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
        key = $1
        ax[key] = case val = $2
          # Remove single quotes
        when /\A'(.*)'\z/ then $1
          # Remove double quotes and unescape string preserving newline characters
        when /\A"(.*)"\z/ then $1.gsub('\n', "\n").gsub(/\\(.)/, '\1')
        else val
        end
      end
    end
  end

  def entries
    @entries.each do |key, value|
      yield key, value
    end
  end
end
