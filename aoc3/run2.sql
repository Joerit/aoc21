create or replace function maxes(iters int) returns void
as $$
declare
	remaining int;
begin
	update input
	set good = b'1';

    for i in 0..iters loop
        update input
		set good = b'0'
    	where good = b'1' 
		and get_bit(val, i) not in (
        	-- psql rounds in the wrong direction, so we need to juggle
			select round(sum(get_bit(val, i)) / count(*)::float + 0.0001)
			from input
        	group by good
			having good = b'1'
			);

		remaining := 0;
		select count(*) into remaining from input where good = b'1';

		if remaining = 1 then
			return;
		end if;
    end loop;
    return ;
end; $$
language plpgsql;

create or replace function mins(iters int) returns void
as $$
declare
	remaining int;
begin
	update input
	set good = b'1';

    for i in 0..iters loop
        update input
		set good = b'0'
    	where good = b'1' 
		and get_bit(val, i) in (
        	-- psql rounds in the wrong direction, so we need to juggle
			select round(sum(get_bit(val, i)) / count(*)::float + 0.0001)
			from input
        	group by good
			having good = b'1'
			);

		remaining := 0;
        select count(*) into remaining from input where good = b'1';
        
        if remaining = 1 then
            return;
        end if;
    end loop;
    return ;
end; $$
language plpgsql;

select maxes(11);
select id, val, val::int from input where good = b'1';

select mins(11);
select id, val, val::int from input where good = b'1';
