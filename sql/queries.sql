--Modifying data:
/*
 Question1
 The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
 
 facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
 
 */
insert into cd.facilities (
        facid,
        name,
        membercost,
        guestcost,
        initialoutlay,
        monthlymaintenance
    )
values (9, 'Spa', 20, 30, 100000, 800);
/*
 Question2
 Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:
 
 Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
 
 */
insert into cd.facilities (
        facid,
        name,
        membercost,
        guestcost,
        initialoutlay,
        monthlymaintenance
    )
select (
        select max(facid)
        from cd.facilities
    ) + 1,
    'Spa',
    20,
    30,
    100000,
    800;
/*
 Question3
 We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
 */
UPDATE cd.facilities
SET initialoutlay = 8000
WHERE facid = 1;
/*
 Question4
 We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
 
 */
update cd.facilities facs
set membercost = (
        select membercost * 1.1
        from cd.facilities
        where facid = 0
    ),
    guestcost = (
        select guestcost * 1.1
        from cd.facilities
        where facid = 0
    )
where facs.facid = 1;
update cd.facilities facs
set membercost = facs2.membercost * 1.1,
    guestcost = facs2.guestcost * 1.1
from (
        select *
        from cd.facilities
        where facid = 0
    ) facs2
where facs.facid = 1;
/*
 Question5
 As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
 */
delete from cd.bookings;
/*
 Question 6
 We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
 */
delete from cd.members
where memid = 37;
-- Basics
/*
 Question1
 How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
 */
SELECT facid,
    name,
    membercost,
    monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
    AND membercost < monthlymaintenance / 50.0;
/*
 Question2
 How can you produce a list of all facilities with the word 'Tennis' in their name?
 */
select *
from cd.facilities
where name like '%Tennis%';
/*
 Question3
 How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
 */
select *
from cd.facilities
where facid in (1, 5);
/*
 Question4
 How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
 */
select memid,
    surname,
    firstname,
    joindate
from cd.members
where joindate >= '2012-09-01';
/*
 Question5
 You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!
 */
select distinct surname
from cd.members
union
select distinct name
from cd.facilities ;

-- Joins

/*
 Question1
 How can you produce a list of the start times for bookings by members named 'David Farrell'?
 */

select bks.starttime 
	from 
		cd.bookings bks
		inner join cd.members mems
			on mems.memid = bks.memid
	where 
		mems.firstname='David' 
		and mems.surname='Farrell'; 

/*
 Question2
 How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
 */

select bks.starttime as start, facs.name as name
	from 
		cd.facilities facs
		inner join cd.bookings bks
			on facs.facid = bks.facid
	where 
		facs.name in ('Tennis Court 2','Tennis Court 1') and
		bks.starttime >= '2012-09-21' and
		bks.starttime < '2012-09-22'
order by bks.starttime; 

/*
 Question3- Sefl Join
How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
 */
select mems.firstname as memfname, mems.surname as memsname, recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname;  


/*
 Question4
 How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
 */

select firstname,surname from cd.members

where memid in (select distinct recommendedby from cd.members)

order by surname,firstname;

select distinct recs.firstname as firstname, recs.surname as surname
	from 
		cd.members mems
		inner join cd.members recs
			on recs.memid = mems.recommendedby
order by surname, firstname;

/*
Question5

How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
 */

select distinct mems.firstname || ' ' ||  mems.surname as member,
	(select recs.firstname || ' ' || recs.surname as recommender 
		from cd.members recs 
		where recs.memid = mems.recommendedby
	)
	from 
		cd.members mems
order by member;

-- Aggregations:

/*
 Question1

 Produce a count of the number of recommendations each member has made. Order by member ID.
 */
    
select recommendedby, count(*) 
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby;

/*
 Question2
Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
 */

 select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by facid; 


/*
 Question3
Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
 */
 select facid, sum(slots) as "Total Slots"
	from cd.bookings
	where
		starttime >= '2012-09-01'
		and starttime < '2012-10-01'
	group by facid
order by "Total Slots";  

/*
 Question4
Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
 */

select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where extract(year from starttime) = 2012
	group by facid, month
order by facid, month; 

/*
 Question5
 Find the total number of members (including guests) who have made at least one booking.

 */

select count(*) from cd.members
where memid in (select distinct memid from cd.bookings);

select count(*) from 
	(select distinct memid from cd.bookings) as mems;

select count(distinct memid) from cd.bookings  ;      


/*
 Question6
 Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
 */

SELECT
    m.surname,
    m.firstname,
    m.memid,
    MIN(b.starttime) AS first_booking
FROM cd.members m
JOIN cd.bookings b
    ON m.memid = b.memid
WHERE b.starttime >= '2012-09-01'
GROUP BY m.memid, m.surname, m.firstname
ORDER BY m.memid;

/*
 Question7
Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
 */

select count(*) over(), firstname, surname
	from cd.members
order by joindate ;

select (select count(*) from cd.members) as count, firstname, surname
	from cd.members
order by joindate;

/*
 Question8
 Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
 */

 select row_number() over(order by joindate), firstname, surname
	from cd.members
order by joindate  ; 

/*
 Question9
 Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
 */

 select facid, total from (
	select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
        	from cd.bookings
		group by facid
	) as ranked
	where rank = 1 ;

-- String:

/*
 Question1
 Output the names of all members, formatted as 'Surname, Firstname'
    */

select surname || ', ' || firstname as name
    from cd.members ;

/* Question2
You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
*/

select memid, telephone
    from cd.members
    where telephone like '%(%' or telephone like '%)%';

select memid, telephone from cd.members where telephone ~ '[()]';  

/* Question3
You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.
*/

select substr (mems.surname,1,1) as letter, count(*) as count 
    from cd.members mems
    group by letter
    order by letter    ;

