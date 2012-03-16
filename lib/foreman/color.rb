require "foreman"

module Foreman::Color

  ANSI = {
    :reset          => 0,
    :black          => 30,
    :red            => 31,
    :green          => 32,
    :yellow         => 33,
    :blue           => 34,
    :magenta        => 35,
    :cyan           => 36,
    :white          => 37,
    :bright_black   => 30,
    :bright_red     => 31,
    :bright_green   => 32,
    :bright_yellow  => 33,
    :bright_blue    => 34,
    :bright_magenta => 35,
    :bright_cyan    => 36,
    :bright_white   => 37,
  }

  def self.enable(io)
    io.extend(self)
  end

  def color?
    return false unless self.respond_to?(:isatty)
    self.isatty && ENV["TERM"]
  end

  def color(name)
    return "" unless color?
    return "" unless ansi = ANSI[name.to_sym]
    "\e[#{ansi}m"
  end

end
