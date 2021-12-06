drop table rawinput;
create table rawinput (
	id serial primary key,
	line varchar
);

copy rawinput(line) from '/gits/aoc21/aoc6/input' (format text);
