drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

copy rawinput(line) from '/gits/aoc21/aoc7/testinput' (format text);

drop table crabs;
create table crabs (
	id serial primary key,
	pos int
);

insert into crabs (pos)
select unnest(string_to_array(line, ',')::int[])
from rawinput;

