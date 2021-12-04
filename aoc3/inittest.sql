drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

drop table input;
create table input (                                          
	id serial primary key,
	val bit(5) not null,
	good bit
);

copy rawinput(line) from '/gits/aoc21/aoc3/testinput' (format text);

insert into input(val)
select
	line::bit(5)
from rawinput;
