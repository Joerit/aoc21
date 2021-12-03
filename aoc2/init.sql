drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

drop table input;
create table input (                                          
	id serial primary key,
	cmd char(7) not null,
	arg int not null
);

copy rawinput(line) from '/gits/aoc21/aoc2/input' (format text);

insert into input(cmd, arg)
select 
	split_part(line, ' ', 1) as cmd,
	split_part(line, ' ', 2)::int as arg
from rawinput;

insert into input (cmd, arg) values 
	('up', 0), 
	('down', 0), 
	('forward', 0), 
	('back', 0); 
