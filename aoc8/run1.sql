drop table unpackeddigits;
create table unpackeddigits (
	lineid int,
	lcode char(7),
	primary key (lineid, lcode)
);

insert into unpackeddigits
select id as lineid, unnest(digitdefs) as lcode
from inputs;

drop table unpackednumbers;
create table unpackednumbers (
	lineid int,
	lcode char(7)
);

insert into unpackednumbers
select id as lineid, unnest(string_to_array(numbers, ' ')) as lcode
from inputs;

drop table digitmap;
create table digitmap (
	lineid int,
	digit int,
	lcode char(7),
	primary key (lineid, digit)
);

-- easy digits first
insert into digitmap
select lineid, 1 as digit, lcode
from unpackeddigits
where length(lcode) = 2;

insert into digitmap
select lineid, 4 as digit, lcode
from unpackeddigits
where length(lcode) = 4;

insert into digitmap
select lineid, 7 as digit, lcode
from unpackeddigits
where length(lcode) = 3;

insert into digitmap
select lineid, 8 as digit, lcode
from unpackeddigits
where length(lcode) = 7;

-- count occurences
select count(*) from unpackednumbers
where length(lcode) in (2, 3, 4, 7)
;
