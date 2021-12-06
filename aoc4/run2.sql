-- first, try to sanitise input
-- split off the drawn numbers
drop table drawnumbers;
create table drawnumbers (
    id serial primary key,
    nr int
);

insert into drawnumbers (nr)
select unnest(string_to_array(line, ',')::int[])              
from rawinput where id = 1
;

-- 
drop table boardlines;
create table boardlines(
	id serial primary key,
	line varchar
);
insert into boardlines
select id, line 
from rawinput 
where id != 1
;

update boardlines
set line = 'N' where line = ''
;

drop table boards;
create table boards(
	id serial primary key,
	board varchar
);

insert into boards(board)
select unnest(string_to_array(fullinputs.line, 'N'))
from (
	select string_agg(line, ' ' order by id) as line
	from boardlines
) as fullinputs
;

delete from boards where id = 1;
update boards
set id = id - 1;

update boards
set board = trim(both from replace(replace(board, '   ', ' '), '  ', ' '));

drop table fields;
create table fields (
	boardid serial,
	fieldid serial,
	x int,
	y int,
	value int
);

insert into fields (boardid, value)
select id as boardid, unnest(string_to_array(board, ' ')::int[])
from boards;

update fields
set x = mod(fieldid-1, 5), y = floor( (fieldid-1) /5 );

drop table winners;
create table winners (
	id serial primary key,
	boardid int
);

-- sanitising done, now to solve
create or replace function calcscore(board int, draw int) returns void
as $$
declare
	lastdraw int;
	result record;
begin
	raise notice 'calcing score';
	select nr into lastdraw from drawnumbers where id = draw;

	select sum(value) * lastdraw as score, boardid into result
    from fields 
    where boardid = board 
	and value not in (
        select nr from drawnumbers order by id limit draw)
	group by boardid;
			
	raise notice 'winner: %, score: %', result.boardid, result.score;

	
end; $$
language plpgsql;

-- sanitising done, now to solve
create or replace function getlastwinner() returns void
as $$
declare
	maxinput int;
	winningboard int;
	winningdraw int;
	checkresult record;
	loopagain boolean; -- we need to check multiple times, multiple boards can win on the same number. if we don't a backlog forms and ordering goes wrong
begin
	select max(id) into maxinput from drawnumbers;
	for i in 1..maxinput loop
		loopagain := true;
		while loopagain loop
			raise notice 'checking i: %', i;
			loopagain := false;
			-- test winning rows
			select count(*) as count, boardid into checkresult
			from fields 
			where 
				boardid not in (select boardid from winners)
			and
				value in (select nr from drawnumbers order by id limit i)
			group by boardid, x 
			having count(*) = 5;
			
			if checkresult.count = 5 then
				loopagain:= true;
				raise notice 'win x, i: %, result: %', i, checkresult;
				insert into winners(boardid) values (checkresult.boardid);
				if (select count(*) from boards) = (select count(*) from winners) then
					-- we have our last winner
					perform calcscore(checkresult.boardid , i);
					return;
				end if;
			end if;

			-- test winning columns
			select count(*) as count, boardid into checkresult
			from fields 
			where
				boardid not in (select boardid from winners)
			and	
				value in ( select nr from drawnumbers order by id limit i)
			group by boardid, y 
			having count(*) = 5;
			
			if checkresult.count = 5 then
				loopagain:= true;
				raise notice 'win y, i: %, result: %', i, checkresult;
				insert into winners(boardid) values (checkresult.boardid);
				if (select count(*) from boards) = (select count(*) from winners) then
					-- we have our last winner
					perform calcscore(checkresult.boardid , i);
					return;
				end if;
			end if;
		end loop;
	end loop;
	return;
end; $$
language plpgsql;

select getlastwinner();
/*create or replace function maxbits() returns bit(12)
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
*/
