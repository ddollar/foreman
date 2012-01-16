require "foreman"

class Foreman::Utils

  def self.parse_concurrency(concurrency)
    begin
      pairs = concurrency.to_s.gsub(/\s/, "").split(",")
      
      default = concurrency.nil? ? 1 : 0
      
      pairs.inject(Hash.new(default)) do |hash, pair|
        process, amount = pair.split("=")
        hash.update(process => amount.to_i)        
      end
    end
  end

end
