select count(*)
from
	(select depth, lag(depth, 1) over wndw as pdepth 
	from input
	window wndw as (
		order by id range 1 preceding)
	) as subq
where depth > pdepth
;
