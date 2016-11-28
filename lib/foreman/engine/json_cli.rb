require "json"
require "foreman/engine"

class Foreman::Engine::JsonCLI < Foreman::Engine

  def startup
  end

  def output(name, data)
    data.to_s.lines.map(&:chomp).each do |message|
      begin
        json_data = JSON.parse(message).to_s
      rescue JSON::ParserError
        json_data = { line: message }.to_json
      end
      json_data.insert(1, "\"process_name\":\"#{name}\", ")
      json_data.insert(1, "\"application_server_timestamp\":\"#{Time.now.utc.to_s}\", ")
      output = json_data
      $stdout.puts output
    end
    $stdout.flush
  rescue Errno::EPIPE
    terminate_gracefully
  end

  def shutdown
  end

end
