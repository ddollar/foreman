require "foreman"
require "foreman/engine"

class Foreman::TmuxEngine < Foreman::Engine

  attr_reader :procfile
  attr_reader :session

  def initialize(procfile, options={})
    @procfile = Foreman::Procfile.new(procfile)
    @options  = options.dup
    @session  = Time.now.to_i
  end

  def start
    assign_colors
    concurrency = Foreman::Utils.parse_concurrency(@options[:concurrency])

    ENV['BUNDLE_GEMFILE'] = nil

    %x{tmux new-session -d -s #{session}}
    procfile.entries.each_with_index do |entry, index|
      name = "#{entry.name}.#{concurrency[entry.name]}"
      if index == 0
        %x{tmux rename-window -t #{session}:#{index} #{name}}
      else
        %x{tmux new-window -t #{session}:#{index} -n #{name}}
      end
      %x{tmux pipe-pane -o -t #{session}:#{index} "gawk '{ printf \\"%%s\\", \\"#{$stdout.color(colors[entry.name])}\\"; print strftime(\\"%%H:%%M:%%S\\"), \\"#{pad_process_name(name)} | #{$stdout.color(:reset)}\\", \\$0; fflush(); }' >> /tmp/foreman.#{session}.log"}
      %x{tmux send-keys -t #{session}:#{index} "#{entry.command}" C-m}
    end
    last_index = procfile.entries.length
    %x{tmux new-window -t #{session}:#{last_index} -n all}
    %x{tmux send-keys -t #{session}:#{last_index} "tail -f /tmp/foreman.#{session}.log" C-m}
    Kernel.exec("tmux attach-session -t #{session}")
  end
end
