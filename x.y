class X
  # {{ some text | more text | fuck }}
  options no_result_var
rule
  template
    : '{{' '}}'                   { [] }
    | '{{' tcontents '}}'         { [:template, val[1]] }

  tcontents
    : telements                   { val }
    | tcontents '|' telements     { val[0] << val[2] }

  telements
    : telement                    { val }
    | telements telement          { val[0] << val[1] }

  telement
    : TEXT                        { [:text, val[0]] }
    | template
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
      when @str.scan(/q(uit)?/i)
         puts "bye!"
         abort
      when text = @str.scan(/[a-zA-Z.\s]+/)
         [:TEXT, text]
      when @str.scan(/{{/)
        %w({{ {{)
      when @str.scan(/}}/)
        %w(}} }})
      when @str.scan(/\|/)
        %w(| |)
      else
        raise "scanner error, motherfucker!"
    end
  end

---- footer

if $0 == __FILE__
=begin
  [:template, [
     [[:text, " you are dumb "]],
     [
       [:text, " and "],
       [:template, [
         [[:text, " really "]],
         [[:text, " fucking stupid "]]]],
       [:text, " i "]
     ],
    [
      [:text, " hope "],
      [:template, [[[:text, " you know "]]]],
      [:text, " "]
    ]
  ]]
=end
doc = <<~S.chomp
{{try it | It can be difficult finding reliable information about food. Test your knowledge with the following question about finding trustworthy nutritional information.
{{expandable | What is the most reliable source for food information that is regulated by the Food and Drug Administration | Nutrition Fact Label }}
}}
S
  #input = "{{ you are dumb | and {{ really | fucking stupid }} i | hope {{ you know }} }}"
  result = X.new(doc).parse
  puts result.inspect
end
