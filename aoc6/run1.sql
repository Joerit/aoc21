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
    s0 int,
    s1 int,
    s2 int,
    s3 int,
    s4 int,
    s5 int,
    s6 int,
    s7 int,
    s8 int
);

insert into spawnings
select 
	0 as day,
	sum(case when timer = 0 then 1 else 0 end) as s0,
	sum(case when timer = 1 then 1 else 0 end) as s1,
	sum(case when timer = 2 then 1 else 0 end) as s2,
	sum(case when timer = 3 then 1 else 0 end) as s3,
	sum(case when timer = 4 then 1 else 0 end) as s4,
	sum(case when timer = 5 then 1 else 0 end) as s5,
	sum(case when timer = 6 then 1 else 0 end) as s6,
	sum(case when timer = 7 then 1 else 0 end) as s7,
	sum(case when timer = 8 then 1 else 0 end) as s8
from initfish;

-- iterate over days
create or replace function buildspawnings(start int, iters int) returns void
as $$
declare
begin
    for i in start..iters loop
		raise notice 'i: %', i;
		insert into spawnings
		select 
			i as day,
			prev.s1 as s0,
			prev.s2 as s1,
			prev.s3 as s2,
			prev.s4 as s3,
			prev.s5 as s4,
			prev.s6 as s5,
			prev.s7 + prev.s0 as s6,
			prev.s8 as s7,
			prev.s0 as s8
		from 
			(select * from spawnings where day = i - 1) as prev
		;
    end loop;
    return ;
end; $$
language plpgsql;

select buildspawnings(1, 80);

select s0+s1+s2+s3+s4+s5+s6+s7+s8
from spawnings 
where
	day = 80  -- cycles are 9 long
;
