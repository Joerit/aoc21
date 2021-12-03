create table input (                                          
	id serial primary key,
	depth int not null
);

copy input(depth) from '/gits/aoc21/aoc1/input' (format text);
