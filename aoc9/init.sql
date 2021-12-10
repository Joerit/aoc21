drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

copy rawinput(line) from '/gits/aoc21/aoc9/input' (format text);

drop table inputs;
create table inputs (
	id serial primary key,
	x smallint,
	y smallint,
	height smallint
);

insert into inputs(x, height)
select id as x, unnest(regexp_split_to_array(line, '')::smallint[]) as height
from rawinput;

update inputs
set y = mod(id-1, 100)+1;
