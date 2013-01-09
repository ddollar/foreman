require "foreman"
require 'open-uri'

class Foreman::Env

  attr_reader :entries

  def initialize(filename)

    if validate_url(filename) then
      @content = load_url(filename)
    else
      @content = File.read(filename)
    end

    @entries = @content.split("\n").inject({}) do |ax, line|
      if line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
        key = $1
        case val = $2
          # Remove single quotes
          when /\A'(.*)'\z/ then ax[key] = $1
          # Remove double quotes and unescape string preserving newline characters
          when /\A"(.*)"\z/ then ax[key] = $1.gsub('\n', "\n").gsub(/\\(.)/, '\1')
          else ax[key] = val
        end
      end
      ax
    end
  end

  def entries
    @entries.each do |key, value|
      yield key, value
    end
  end

  def load_url(url)
    open(url) do |f|                                                  
      f.read                                                                  
    end
  end

  def validate_url(url)
    u = URI.parse url                                                           
    return true if u.class == URI::HTTP or u.class == URI::HTTPS                
    false
  end

end
