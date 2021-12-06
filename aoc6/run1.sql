-- first, try to sanitise input
drop table initfish;
create table initfish (
	timer int
);
insert into initfish (timer)
select unnest(string_to_array(line, ',')::int[])
from rawinput;

drop table spawnings;
create table spawnings (
    day int primary key,
    spawners int
);

-- they count 0 as an extra day because they suck lmao ayyy so we have to +1
insert into spawnings(day, spawners)
select timer+1, count(timer)
from initfish
group by timer;

-- insert some '0's to simplify further handling
insert into spawnings(day, spawners)
values 
	(1, 0),
	(0, 0),
	(-1, 0),
	(-2, 0),
	(-3, 0);

-- iterate over days
create or replace function buildspawnings(start int, iters int) returns void
as $$
declare
begin
    for i in start..iters loop
		raise notice 'i: %', i;
		insert into spawnings
		select i as day, (s1.spawners + s2.spawners) as spawners
		from 
			(select spawners from spawnings where day = i - 7) as s1,
			(select spawners from spawnings where day = i - 9) as s2
		;
    end loop;
    return ;
end; $$
language plpgsql;

select buildspawnings(6, 80);

select sum(spawners)
from spawnings 
where
	day > 80 - 10  -- cycles are 9 long
;
