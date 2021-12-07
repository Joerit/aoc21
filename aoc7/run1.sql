select sum(abs(pos - median)) as total
from
	crabs,
	(select  percentile_cont(0.5) within group (order by pos) as median from crabs) as med
;
