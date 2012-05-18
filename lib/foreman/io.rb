require "foreman"

class Foreman::IO
  def self.open
    IO.pipe
  end

  # replace IO.pipe with PTY if available
  begin
    require "pty"
    if PTY.respond_to? :open
      def self.open
        PTY.open.tap { |r,w|
          if w.respond_to? :raw!
            w.raw!
          else
            system("stty raw", :in => w)
          end
        }
      end
    end
  rescue LoadError
  end
end
