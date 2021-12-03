create or replace function run1() returns float
as $$
declare
	up int;
	fwd int;
	dwn int;
	bck int;
	cur cursor for 
		select sum(arg) 
		from input
		group by cmd
		order by cmd;
begin
	open cur;
	fetch from cur into bck;
	fetch from cur into dwn;
	fetch from cur into fwd;
	fetch from cur into up;

	return (dwn - up) * (fwd - bck);
end; $$
language plpgsql;

select run1();
