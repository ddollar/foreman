ANSI_TOKEN = /\e\[(?:\??\d{1,4}(?:;\d{0,4})*)?[A-Za-z]|\e=|\e>/
NEWLINE_TOKEN = /\n/
TOKENIZER = Regexp.new("(#{ANSI_TOKEN}|#{NEWLINE_TOKEN})")

class Buffer
  @buffer = ''

  def initialize(initial = '')
    @buffer = initial.dup
    @fd = File.open("/tmp/buffer.#{initial}.log", "w+")
    @fd.sync = true
  end

  def each_token
    remainder = ''
    @fd.puts @buffer.split(TOKENIZER).inspect
    @buffer.split(TOKENIZER).each do |token|
      if token.include?("\e") && !token.match(ANSI_TOKEN)
        remainder << token
      else
        yield token unless token.empty?
      end
    end
    @buffer = remainder
  end

  def gets
    return nil unless @buffer.include?("\n")

    line, @buffer = @buffer.split("\n", 2)
    line
  end

  def write(data)
    @buffer << data
    @fd.puts "write: #{data.inspect}"
  end
end
