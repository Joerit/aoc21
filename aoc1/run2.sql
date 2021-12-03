-- select d1, d2, d3, d4, d2 + d3 + d4 as dn, d1 + d2 + d3 as dc
select count(*)
from
	(select 
		depth as d1, 
		lag(depth, 1) over w as d2, 
		lag(depth, 2) over w as d3, 
		lag(depth, 3) over w as d4 
	from input
	window w as (
		order by id
		)
	) as subq
where d2 + d3 + d4 < d1 + d2 + d3
;
