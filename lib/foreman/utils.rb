require "foreman"

class Foreman::Utils

  # Converts "alpha=3,bravo=2" into { "alpha" => 3, "bravo" => 2}
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

  # Converts "alpha=300 MB" into { "alpha" => "300 MB" }
  # Converts "alpha=25%,bravo=10%" into { "alpha" => "25%", "bravo" => "10%" }
  # Converts "25%" into { "alpha" => "25%", "bravo" => "25%" }
  # Converts "25%, cameo=15%" into { "alpha" => "25%", "bravo" => "25%", "cameo" => "15%" }
  def self.parse_process_attribute(process_attributes)
    begin
      pairs = process_attributes.to_s.split(",")

      if first_pair = pairs[0] && first_pair !~ /=/
        default = pairs.shift.strip # drop the leading default string
      end
      
      pairs.inject(Hash.new(default)) do |hash, pair|
        process, amount = pair.strip.split("=")
        hash.update(process => amount)
      end
    end
  end

end
