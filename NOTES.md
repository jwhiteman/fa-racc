abc

       concat
    concat
  s:a    s:b   s:c

a   => s:a
ab  => concat(s:a, s:b)
abc => concat(concat(s:a, s:b), s:c)


(a|b)

       union
	  s:a  s:b

(a|b)c
       concat
	 union
	s:a  s:b   s:c


TODO:
look: how can we get `2+2*2` to work as well as `2*2+2`
so...revisit the calculator grammar

have an answer to the question of precedence & left association
