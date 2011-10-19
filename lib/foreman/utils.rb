require "foreman"

class Foreman::Utils

  def self.parse_concurrency(concurrency)
    begin
      pairs = concurrency.to_s.gsub(/\s/, "").split(",")
      pairs.inject(Hash.new(1)) do |hash, pair|
        process, amount = pair.split("=")
        hash.update(process => amount.to_i)        
      end
    end
  end

end
