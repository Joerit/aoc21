drop table inputneighbours;
create table inputneighbours(
	id serial primary key,
	x smallint,
	y smallint,
	height smallint,
	xp smallint,
	xm smallint,
	yp smallint,
	ym smallint
);

-- insert neightbours
insert into inputneighbours (id, x, y, height, xp)
select i.id, i.x, i.y, i.height, xp.height
from inputs as i
left join inputs as xp on (i.y = xp.y and i.x = (xp.x -1))
;

update inputneighbours as inei
set xm = xm.height
from inputs as i
left join inputs as xm on (i.y = xm.y and i.x = (xm.x +1))
where inei.id = i.id
;

update inputneighbours as inei
set yp = yp.height
from inputs as i
left join inputs as yp on (i.y = (yp.y -1) and i.x = yp.x)
where inei.id = i.id
;

update inputneighbours as inei
set ym = ym.height
from inputs as i
left join inputs as ym on (i.y = (ym.y +1) and i.x = ym.x)
where inei.id = i.id
;

-- add missing neighbours as 10
update inputneighbours
set xp = 10 where xp is null;
update inputneighbours
set xm = 10 where xm is null;
update inputneighbours
set yp = 10 where yp is null;
update inputneighbours
set ym = 10 where ym is null;

-- sim of heights of local mins
select sum(height+1)
from inputneighbours
where height < xp and height < xm and height < yp and height < ym;

