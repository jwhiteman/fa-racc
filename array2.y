class X
  options no_result_var
rule
  array   : '[' contents ']' { val[1] }
          | '[' ']'          { [] }

  contents: ITEM              { val }
          | contents ',' ITEM { val[0].push val[2]; val[0] }
end

---- inner
  require "strscan"
  require "pry"

  def initialize(str)
    @str = StringScanner.new(str)

    super()
  end

  def parse
    do_parse
  end

  def next_token
    return if @str.eos?

    case
      when @str.scan(/\s+/)
         next_token
      when @str.scan(/\[/)
        ["[", "["]
      when @str.scan(/\]/)
        ["]", "]"]
      when @str.scan(/,/)
        [",", ","]
      when text = @str.scan(/[0-9]+/)
        [:ITEM, text]
      else
        raise "scanner error"
    end
  end

---- footer

if $0 == __FILE__
  print "> "
  while input = gets.chomp
    result = X.new(input).parse
    puts result.inspect
    print "> "
  end
end
