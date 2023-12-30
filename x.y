class X
  options no_result_var
rule
  doc
    : TEXT              { [:text, val] }
    | BOLD TEXT BOLD    { val }
end

---- inner
  require "strscan"
  require "pry"

  def initialize(str)
    @str = StringScanner.new(str)
binding.pry

    super()
  end

  def parse
    do_parse
  end

  def next_token
    return if @str.eos?

    case
      when @str.scan(/'''/)
        [:BOLD, "'''"]
      when text = @str.scan(/['a-z]+/)
        [:TEXT, text]
      else
        raise "scanner error"
    end
  end

---- footer

if $0 == __FILE__
  input  = "'''hi'''"
  result = X.new(input).parse
  puts result.inspect
end
