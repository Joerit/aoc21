-- https://en.wikipedia.org/wiki/1_%2B_2_%2B_3_%2B_4_%2B_%E2%8B%AF
-- sum(1,2,3,...,n) = n*(n+1)/2
select 
	sum( 
		abs(pos - avg) * (abs(pos - avg)+1) 
		/ 2 )
	as total
from
	crabs,
	(select floor(avg(pos)) as avg from crabs) as avg
;
