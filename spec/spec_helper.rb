require "rubygems"
require "rspec"
require "fakefs/safe"
require "fakefs/spec_helpers"

$:.unshift "lib"

def mock_error(subject, message)
  mock_exit do
    mock(subject).puts("ERROR: #{message}")
    yield
  end
end

def mock_exit(&block)
  block.should raise_error(SystemExit)
end

def write_foreman_config(app)
  File.open("/etc/foreman/#{app}.conf", "w") do |file|
    file.puts %{#{app}_processes="alpha bravo"}
    file.puts %{#{app}_alpha="1"}
    file.puts %{#{app}_bravo="2"}
  end
end

def write_procfile(procfile="Procfile")
  File.open(procfile, "w") do |file|
    file.puts "alpha: ./alpha"
    file.puts "bravo: ./bravo"
  end
end

Rspec.configure do |config|
  config.color_enabled = true
  config.include FakeFS::SpecHelpers
  config.mock_with :rr
end
