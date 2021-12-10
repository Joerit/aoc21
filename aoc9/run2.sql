drop table inputneighbours;
create table inputneighbours(
	id serial primary key,
	x smallint,
	y smallint,
	height smallint,
	xp smallint,
	xpid int references inputneighbours (id),
	xm smallint,
	xmid int references inputneighbours (id),
	yp smallint,
	ypid int references inputneighbours (id),
	ym smallint,
	ymid int references inputneighbours (id),
	basin smallint
);
create sequence inp_bas_seq;
ALTER SEQUENCE inp_bas_seq OWNED BY inputneighbours.basin;

-- insert neightbours
insert into inputneighbours (id, x, y, height, xp, xpid)
select i.id, i.x, i.y, i.height, xp.height, xp.id
from inputs as i
left join inputs as xp on (i.y = xp.y and i.x = (xp.x -1))
;

update inputneighbours as inei
set xm = xm.height, xmid = xm.id
from inputs as i
left join inputs as xm on (i.y = xm.y and i.x = (xm.x +1))
where inei.id = i.id
;

update inputneighbours as inei
set yp = yp.height, ypid = yp.id
from inputs as i
left join inputs as yp on (i.y = (yp.y -1) and i.x = yp.x)
where inei.id = i.id
;

update inputneighbours as inei
set ym = ym.height, ymid = ym.id
from inputs as i
left join inputs as ym on (i.y = (ym.y +1) and i.x = ym.x)
where inei.id = i.id
;

-- add missing neighbours as 9
update inputneighbours
set xp = 9 where xp is null;
update inputneighbours
set xm = 9 where xm is null;
update inputneighbours
set yp = 9 where yp is null;
update inputneighbours
set ym = 9 where ym is null;

-- init basins
update inputneighbours
set basin = nextval('inp_bas_seq')
where height < xp and height < xm and height < yp and height < ym;

create or replace function expandbasins() returns void
as $$
declare
	countnull int;
begin
	-- check wether a field that needs to be assigned to a basin still exists (i.e. a not9)
	while exists(select * from inputneighbours where basin is null and height <> 9 limit 1) loop
		-- 4 times the same, could probably become a bigger join but can't brain
		-- join on id = x-1.id, and insert the basin of field x-1 (if not null)
		update inputneighbours
		set basin = other.basin
		from inputneighbours as i
		left join inputneighbours as other on (i.xmid = other.id)
		where
			inputneighbours.height <> 9
		and inputneighbours.basin is null
		and inputneighbours.id = i.id
		and other.basin is not null
		;
		-- do the same for field x+1, y-1, y+1
		update inputneighbours
		set basin = other.basin
		from inputneighbours as i
		left join inputneighbours as other on (i.xpid = other.id)
		where
			inputneighbours.height <> 9
		and inputneighbours.basin is null
		and inputneighbours.id = i.id
		and other.basin is not null
		;
		update inputneighbours
		set basin = other.basin
		from inputneighbours as i
		left join inputneighbours as other on (i.ymid = other.id)
		where
			inputneighbours.height <> 9
		and inputneighbours.basin is null
		and inputneighbours.id = i.id
		and other.basin is not null
		;
		update inputneighbours
		set basin = other.basin
		from inputneighbours as i
		left join inputneighbours as other on (i.ypid = other.id)
		where
			inputneighbours.height <> 9
		and inputneighbours.basin is null
		and inputneighbours.id = i.id
		and other.basin is not null
		;
	end loop;

end; $$
language plpgsql;

select expandbasins();

select basin, count(*) as count
from inputneighbours
where basin is not null
group by basin
order by count desc
limit 3;
