create or replace function maxbits() returns bit(12)
as $$
declare
	tmp int;
	maxbits bit(12) := '000000000000';
begin
	for i in 0..11 loop
		select 
		round(sum(get_bit(val, i)) / max(id)::float) into tmp
        from input;
		
		maxbits := set_bit(maxbits, i, tmp);

	end loop;
	return maxbits;
end; $$
language plpgsql;

drop table cache;
create table cache (
	id serial primary key,
	val bit(12)
);

insert into cache values (1, maxbits());
select val as maxbits, ~ val as minbits, val::int as maxbitsint, (~ val)::int as minbitsint, val::int * (~val)::int as result
from cache where id = 1;
