class X
  options no_result_var
rule
  regex
    : union
    | simpleregex

  union
    : regex BAR simpleregex { Union.new(val[0], val[2]) }

  simpleregex
    : concatenation
    | basicregex

  concatenation
    : simpleregex basicregex { Concat.new(val[0], val[1]) }

  basicregex
    : star
    | question
    | plus
    | elementaryregex

  star
    : elementaryregex STAR  { Closure.new(val[0]) }

  question
    : elementaryregex QUESTION { Maybe.new(val[0]) }

  question
    : elementaryregex PLUS { OneOrMore.new(val[0]) }

  elementaryregex
    : group
    | char { Symbol.new(val[0]) }

  group
    : LPAREN regex RPAREN { val[1] }

  char
    : CHAR
end

---- inner
  require "strscan"
  require "pry"

  class Symbol < Struct.new(:char)
    def inspect
      "Symbol(#{char})"
    end
  end
  class Concat < Struct.new(:l, :r)
    def inspect
      "Concat(#{l.inspect}, #{r.inspect})"
    end
  end
  class Union < Struct.new(:l, :r)
    def inspect
      "Union(#{l.inspect}, #{r.inspect})"
    end
  end
  class Closure < Struct.new(:rexp)
    def inspect
      "Closure(#{rexp.inspect})"
    end
  end
  class Maybe < Struct.new(:rexp)
    def inspect
      "Maybe(#{rexp.inspect})"
    end
  end
  class OneOrMore < Struct.new(:rexp)
    def inspect
      "OneOrMore(#{rexp.inspect})"
    end
  end

  # grammar stolen from:
  # https://www.cs.sfu.ca/~cameron/Teaching/384/99-3/regexp-plg.html

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
      when char = @str.scan(/[a-z]/i)
        [:CHAR, char]
      when @str.scan(/\(/)
        [:LPAREN, "("]
      when @str.scan(/\)/)
        [:RPAREN, ")"]
      when @str.scan(/\|/)
        [:BAR, "|"]
      when @str.scan(/\*/)
        [:STAR, "*"]
      when @str.scan(/\+/)
        [:PLUS, "+"]
      when @str.scan(/\?/)
        [:QUESTION, "?"]
      else
        raise "scanner error"
    end
  end

---- footer

if $0 == __FILE__
  loop do
    print("> ")
    input  = gets.chomp

    break if input =~ /q(uit)?/i

    result = X.new(input).parse
    # binding.pry
    puts result.inspect
  end
end
