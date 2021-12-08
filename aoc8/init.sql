drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

copy rawinput(line) from '/gits/aoc21/aoc8/input' (format text);

drop table inputs;
create table inputs (
	id serial primary key,
	digitdefs char(7)[], -- every digit once
	numbers text 
);

insert into inputs(digitdefs, numbers)
select string_to_array((string_to_array(line, ' | '))[1], ' ') as digitdefs, (string_to_array(line, ' | '))[2] as numbers
from rawinput;

