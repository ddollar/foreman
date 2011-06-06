require "rubygems"
require "rspec"
require "fakefs/safe"
require "fakefs/spec_helpers"

$:.unshift File.expand_path("../../lib", __FILE__)

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
    file.puts "" # Check that a blank line does not blow things up
    file.puts "alpha: ./alpha"
    file.puts "bravo: ./bravo"
  end
  File.expand_path(procfile)
end

def write_erb_procfile(procfile="Procfile")
  File.open(procfile, 'w') do |file|
    file.puts <<-ERB
      <% if ENV['ERB_1'] == 'true' %>
        alpha: ./erb1/alpha
        bravo: ./erb1/bravo
      <% elsif ENV['ERB_2'] == 'true' %>
        alpha: ./erb2/alpha
        bravo: ./erb2/bravo
      <% else %>
        alpha: ./alpha
        bravo: ./bravo
      <% end %>
    ERB
  end
  File.expand_path(procfile)
end

def load_export_templates_into_fakefs(type)
  FakeFS.deactivate!
  files = Dir[File.expand_path("../../data/export/#{type}/**", __FILE__)].inject({}) do |hash, file|
    hash.update(file => File.read(file))
  end
  FakeFS.activate!
  files.each do |filename, contents|
    File.open(filename, "w") do |f|
      f.puts contents
    end
  end
end

def example_export_file(filename)
  FakeFS.deactivate!
  data = File.read(File.expand_path("../resources/export/#{filename}", __FILE__))
  FakeFS.activate!
  data
end

Rspec.configure do |config|
  config.color_enabled = true
  config.include FakeFS::SpecHelpers
  config.mock_with :rr
end
