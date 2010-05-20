require "fakefs/spec_helpers"
require "rspec"

$:.unshift "lib"

# def stub_configuration
#   config = mock(Foreman::Configuration)
#   Foreman::Configuration.stub(:new).and_return(config)
#   config  
# end
# 
# 
# def stub_export_upstart
#   upstart = mock(Foreman::Export::Upstart)
#   Foreman::Export::Upstart.stub(:new).and_return(upstart)
#   upstart
# end

def mock_error(subject, message)
  mock_exit do
    mock(subject).puts("ERROR: #{message}")
    yield
  end
end

def mock_exit(&block)
  block.should raise_error(SystemExit)
end

# def stub_engine
#   engine = mock(Foreman::Engine)
#   stub(Foreman::Engine).new { engine }
#   engine
# end
# 
def write_foreman_config(app)
  File.open("/etc/foreman/#{app}.conf", "w") do |file|
    file.puts %{#{app}_processes="alpha bravo"}
    file.puts %{#{app}_alpha="1"}
    file.puts %{#{app}_bravo="2"}    
  end
end

def write_procfile(procfile="Procfile")
  File.open(procfile, "w") do |file|
    file.puts "alpha ./alpha"
    file.puts "bravo ./bravo"
  end
end

Rspec.configure do |config|
  config.color_enabled = true
  config.include FakeFS::SpecHelpers
  config.mock_with :rr
end
