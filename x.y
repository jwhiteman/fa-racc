class X
  options no_result_var
rule
   prog: matrix OK

   matrix
     : array         { [ val[0] ] }
     | matrix array  { val[0] << val[1] }

   array : seq EOL

   seq
     : num           { [ val[0] ] }
     | seq "," num   { val[0] << val[2] }

   num : NUM
end

---- inner
  require "strscan"
  require "pry"

=begin
- val is always an array, however, that might only exist if you set an action
- you can add boxes as you move up (val will accomplish this), but can never not have an array
- if you have an action, val[0] might be the default behavior?

- for the one-or-more pattern, the 'one' - w/o any action, doesn't do any boxing
- the many, at least for the first arrival will have a 1d list

- consider this
many
  : one
  | many one

at the arrival of one, let's say it's "1" (reminder: won't be boxed w/o an action)
at the arrival of many-one, it will be ["1", "2"], and this will become the
many part of the many-one for the next arrival:
[["1", "2"], "3"]
and the next?
[ [["1", "2"], "3"], "4" ]

this would be the behavior if you set the many-one action to: { val }

what will this be if you put val[0] ? - prediction - the very first arrival of one
...and nothing more.

the pattern you probably want:
1. establish the 'one' as the base case. it's a list builder. so return [one]
2. so on the many-one, you can do many << latest, which on the first arrival
   is tantamount to [one] << latest.

calculator pattern:
 seq
   : num
   | seq "," num { val[0] + val[2] }

list builder pattern:
 seq
   : num         { [ val[0] ] }
   | seq "," num { val[0] << val[2] }

hash builder pattern:
seq
  : num {
    { val[0] => rand(1000) }
  }
  | seq "," num {
    h = val[0]
    k = val[2]

    h[k] = rand(1000)
    h # remember - this is basically like ruby's reduce...
  }

string builder pattern:
 seq
   : num { val[0].to_s }
   | seq "," num { val[0] + val[2] }
for one-or-many, you must decide what the production type must be. an int?

a list? a hash?. then make sure that the 'one' is of that type. on the
arrival of many-one, the many then will represent the accumulator. sum it,
append to it, add keys, etc etc.

this is just like ruby reduce; complete with the quirk that you've got
to make sure you return the accumulator at the end of the action

this returns the first number. why? because the default action, i believe,
is just val[0]; num (in this case) will be set to first. there is no
reduction pattern here, just first
 deq : seq

 seq
   : num
   | seq "," num

 num : NUM

[1, 2, 3].reduce { |acc, i| acc }

this has the same behavior - it will just return 1.
=end

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
      when @str.scan(/ok/i)
         [:OK, "ok"]
      when @str.scan(/\n/)
         [:EOL, "\n"]
      when @str.scan(/\s+/)
         next_token
      when @str.scan(/,/)
        [",", ","]
      when text = @str.scan(/[0-9]+/)
        [:NUM, text]
      else
        raise "scanner error"
    end
  end

---- footer

if $0 == __FILE__
  #print "> "
  #while input = gets.chomp
input = <<~M.chomp
1, 2, 3, 4
5, 6, 7, 8
9, 10, 11, 12
OK
M
    result = X.new(input).parse
    puts result.inspect
    #print "> "
  #end
end
