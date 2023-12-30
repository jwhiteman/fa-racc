class X
  options no_result_var
rule
    rexpr    : rexpr PLUS rterm | rterm
    rterm    : rterm rfactor | rfactor
    rfactor  : rfactor STAR | rprimary
    rprimary : A | B
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
      when @str.scan(/\+/)
        [:PLUS, "+"]
      when @str.scan(/\*/)
        [:STAR, "*"]
      when @str.scan(/a/i)
        [:A, "a"]
      when @str.scan(/b/i)
        [:B, "b"]
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
    puts result.inspect
  end
end
