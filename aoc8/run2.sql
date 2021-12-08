drop table unpackeddigits;
create table unpackeddigits (
	lineid int,
	lcode char(1)[],
	primary key (lineid, lcode)
);

insert into unpackeddigits
select id as lineid, regexp_split_to_array(unnest(digitdefs), '') as lcode
from inputs
;

drop table unpackednumbers;
create table unpackednumbers (
	lineid int,
	d1 char(1)[],
	d2 char(1)[],
	d3 char(1)[],
	d4 char(1)[]
);

insert into unpackednumbers
select id as lineid, 
	regexp_split_to_array((string_to_array(numbers, ' '))[1], '') as d1,
	regexp_split_to_array((string_to_array(numbers, ' '))[2], '') as d2,
	regexp_split_to_array((string_to_array(numbers, ' '))[3], '') as d3,
	regexp_split_to_array((string_to_array(numbers, ' '))[4], '') as d4
from inputs;

drop table digitmap;
create table digitmap (
	lineid int,
	digit int,
	lcode char(1)[],
	primary key (lineid, digit)
);

-- easy digits first
insert into digitmap
select lineid, 1 as digit, lcode
from unpackeddigits
where array_length(lcode, 1) = 2;

insert into digitmap
select lineid, 4 as digit, lcode
from unpackeddigits
where array_length(lcode, 1) = 4;

insert into digitmap
select lineid, 7 as digit, lcode
from unpackeddigits
where array_length(lcode, 1) = 3;

insert into digitmap
select lineid, 8 as digit, lcode
from unpackeddigits
where array_length(lcode, 1) = 7;

-- now the hard ones
-- deduce 3s
insert into digitmap
select ud.lineid as lineid, 3 as digit, ud.lcode as lcode
from 
	 (select lcode, lineid from unpackeddigits where array_length(lcode, 1) = 5 ) as ud -- 5 segs need to be 2, 3 or 5
join (select lcode, lineid from digitmap where digit = 1) as ones on (ones.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			ud.lcode, ones.lcode[1]
		), ones.lcode[2]
	), 1) = 3
;

--deduce 2s
insert into digitmap
select ud.lineid as lineid, 2 as digit, ud.lcode as lcode
from 
	 (select lcode, lineid from unpackeddigits where array_length(lcode, 1) in (5)) as ud
join (select lcode, lineid from digitmap where digit = 4) as fours on (fours.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			array_remove( 
				array_remove( 
					ud.lcode, fours.lcode[1]
				), fours.lcode[2]
			), fours.lcode[3]
		), fours.lcode[4]
	), 1) = 3
;
-- deduce 5s
-- 5-4 and 3-4 both count to 2, so filter out threes too
insert into digitmap
select ud.lineid as lineid, 5 as digit, ud.lcode as lcode
from 
	(select ud.lcode, ud.lineid 
	from unpackeddigits as ud
	join (select * from digitmap where digit = 3) as threes
		on ud.lineid = threes.lineid 
	where
		array_length(ud.lcode, 1) in (5)
	and ud.lcode != threes.lcode
	 ) as ud
join (select lcode, lineid from digitmap where digit = 4) as fours on (fours.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			array_remove( 
				array_remove( 
					ud.lcode, fours.lcode[1]
				), fours.lcode[2]
			), fours.lcode[3]
		), fours.lcode[4]
	), 1) = 2
;

-- deduce 6s
insert into digitmap
select ud.lineid as lineid, 6 as digit, ud.lcode as lcode
from 
	 (select lcode, lineid from unpackeddigits where array_length(lcode, 1) = 6 ) as ud -- 6 segs need to be 0, 6 or 9
join (select lcode, lineid from digitmap where digit = 1) as ones on (ones.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			ud.lcode, ones.lcode[1]
		), ones.lcode[2]
	), 1) = 5
;

-- deduce 9s
insert into digitmap
select ud.lineid as lineid, 9 as digit, ud.lcode as lcode
from 
	 (select lcode, lineid from unpackeddigits where array_length(lcode, 1) = 6) as ud
join (select lcode, lineid from digitmap where digit = 3) as threes on (threes.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			array_remove( 
				array_remove( 
					array_remove( 
						ud.lcode, threes.lcode[1]
					), threes.lcode[2]
				), threes.lcode[3]
			), threes.lcode[4]
		), threes.lcode[5]
	), 1) = 1
;

-- once again, 6-3 and 0-3 both equal 2, so filter out 6
insert into digitmap
select ud.lineid as lineid, 0 as digit, ud.lcode as lcode
from 
	(select ud.lcode, ud.lineid 
	from unpackeddigits as ud
	join (select * from digitmap where digit = 6) as sixes
		on ud.lineid = sixes.lineid 
	where
		array_length(ud.lcode, 1) = 6
	and ud.lcode != sixes.lcode
	 ) as ud
join (select lcode, lineid from digitmap where digit = 3) as threes on (threes.lineid = ud.lineid)
where
	array_length(array_remove(
		array_remove( 
			array_remove( 
				array_remove( 
					array_remove( 
						ud.lcode, threes.lcode[1]
					), threes.lcode[2]
				), threes.lcode[3]
			), threes.lcode[4]
		), threes.lcode[5]
	), 1) = 2
;

-- count total
select sum(number) from (
	select dm1.digit*1000 + dm2.digit*100 + dm3.digit*10 + dm4.digit as number
	from unpackednumbers as un
	join digitmap as dm1 on (un.lineid = dm1.lineid and un.d1 @> dm1.lcode and un.d1 <@ dm1.lcode )
	join digitmap as dm2 on (un.lineid = dm2.lineid and un.d2 @> dm2.lcode and un.d2 <@ dm2.lcode )
	join digitmap as dm3 on (un.lineid = dm3.lineid and un.d3 @> dm3.lcode and un.d3 <@ dm3.lcode )
	join digitmap as dm4 on (un.lineid = dm4.lineid and un.d4 @> dm4.lcode and un.d4 <@ dm4.lcode )
) as a;



