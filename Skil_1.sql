use progresstracker_v6;
select courses.courseNumber, courses.courseCredits from courses
inner join TrackCourses on courses.courseNumber, TrackCourses.courseNumber;

-- 1:
-- Birtið lista af öllum áföngum sem geymdir eru í gagnagrunninum.
-- Áfangarnir eru birtir í stafrófsröð
delimiter $$
drop procedure if exists CourseList $$

create procedure CourseList()
begin
	select * from courses ORDER BY courseName;
end $$
delimiter ;


-- 2:
-- Birtið upplýsingar um einn ákveðin áfanga.
delimiter $$
drop procedure if exists SingleCourse $$

create procedure SingleCourse(Course_Nu char(10))
begin
	select * from courses where courseNumber = courseNu;
end $$
delimiter ;


-- 3:
-- Nýskráið áfanga í gagnagrunninn.
-- Það þarf að skrá áfanganúmerið, áfangaheitið og einingafjöldann
delimiter $$
drop procedure if exists NewCourse $$

create procedure NewCourse(Course_Nu char(10), course_Na varchar(75), course_Cr tinyint(4))
begin
	insert into courses(CourseNumber, CourseName , CourseCredits) 
	values(courseNu, courseNa, courseCr);
end $$
delimiter ;


-- 4:
-- Skrifið Stored Procedure sem uppfærir áfanga
-- Uppfærið réttan kúrs með því að senda courseNumber sem færibreytu.
-- row_count() fallið er hér notað til að birta fjölda raða sem voru uppfærðar.
delimiter $$
drop procedure if exists UpdateCourse $$

create procedure UpdateCourse(courseNu char(10), courseNa varchar(75), courseCr tinryint(4))
begin
	UPDATE courses
SET 
    courseNames = courseNa, courseCredit = courseCr
WHERE
    CourseNumber = courseNu
SELECT
	select row_count() as 'Updated'										 
end $$
delimiter ;


-- 5:
-- Skrifið SP sem eyðir áfanga.
-- ATH: Ef verið er að nota áfangann einhversstaðar(sé hann skráður á TrackCourses töfluna) þá má EKKI eyða honum.
-- Sé hins vegar hvergi verið að nota hann má eyða honum úr bæði Courses og Restrictor töflunum.
delimiter $$
drop procedure if exists DeleteCourse $$

create procedure DeleteCourse(courseNu char(10))
begin
	delete from courses
	where not exists
		(select courseNumber from trackcourses where trackcourses.courseNumber = courseNu);
end $$
delimiter ;


-- 6:
-- fallið skilar heildarfjölda allra áfanga í grunninum
delimiter $$
drop function if exists NumberOfCourses $$
    
create function NumberOfCourses()
returns int
begin
	select count(courseNumber) from courses;
end $$
delimiter ;


-- 7:
-- Fallið skilar heildar einingafjölda ákveðinnar námsleiðar(Track)
-- Senda þarf brautarNumer inn sem færibreytu
delimiter $$
drop function if exists TotalTrackCredits $$
    
create function TotalTrackCredits(brautNu)
returns int
begin
	declare samtala int;
	set samtala = 0;				    
	
  select sum(courseCredits) into samtala				    
    from courses
    inner join TrackCourses on (courses.courseNumber = TrackCourses.courseNumber)
    where trackcourses.trackID = brautNu;					    
end $$
delimiter ;


-- 8: 
-- Fallið skilar heildarfjölda áfanga sem eru í boði á ákveðinni námsleið
delimiter $$
drop function if exists TotalNumberOfTrackCourses $$
    
create function TotalNumberOfTrackCourses(brautNu int)
returns int
begin
	return (select count(trackID) 
				from trackcourses
				where trackID = brautNu);
end $$
delimiter ;


-- 9:
-- Fallið skilar true ef áfanginn finnst í töflunni TrackCourses
delimiter $$
drop function if exists CourseInUse $$
    
create function CourseInUse()
returns int
begin
	declare bool boolean;
	set bool = false;
    
	if exists (select courseNumber from TrackCourses 
		where courseNumber = course) then
		set bool = True;
	end if;

	return bool;
end $$
delimiter ;


-- 10:
-- Fallið skilar true ef árið er hlaupár annars false
delimiter $$
drop function if exists IsLeapyear $$

create function IsLeapYear()
returns boolean
begin
	DECLARE is_leap boolean;
	DECLARE ENTER_YEAR INTEGER;

	If (Enter_Year % 400 = 0
	OR (Enter_Year % 4 =0 and not Enter_Year % 100 = 0))
	then set is_leap = true;
	ELSE SET is_leap = false;
	end if;
  RETURN is_leap;
end $$
delimiter ;


-- 11:
-- Fallið reiknar út og skilar aldri ákveðins nemanda // rosaleg ritvilla hér haha
delimiter $$
drop function if exists StudentAge $$
    
create function StudentAge(studID int)
returns int
begin
	declare age int;
	set age = 0;

	select year(from_days(datediff(now(),dob))) into age
	from Students
	where studentID = studID;

	return age;
end $$
delimiter ;

-- 12:
-- Fallið skilar fjölda þeirra eininga sem nemandinn hefur tekið(lokið)
delimiter $$
drop function if exists StudentCredits $$
    
create function StudentCredits(studID)
returns int
begin
	declare units int;
	set units = 0;

	select count(passed) into units 
	from Registration
	where  studentID = studID;

	return units;
end $$
delimiter ;

-- 13:
-- Hér þarf að skila Brautarheiti, heiti námsleiðar(Track) og fjölda áfanga
-- Aðeins á að birta upplýsingar yfir brautir sem hafa námsleiðir sem innihalda áfanga.
delimiter $$
drop procedure if exists TrackTotalCredits $$

create procedure TrackTotalCredits()
begin
	select trackName, sum(courses.courseCredits) from tracks
	inner join trackcourses on (tracks.trackID = trackcourses.trackID) inner join courses on (trackcourses.courseNumber = courses.courseNumber)
		group by trackName;
end $$
delimiter ;


-- 14:
-- Hér þarf skila lista af öllum áföngum ásamt takmörkum(restrictos) og tegund þeirra.
-- Hafi áfangi enga undanfara eða samfara þá birtast þeir samt í listanum.
delimiter $$
drop procedure if exists CourseRestrictorList $$

create procedure CourseRestrictorList()
begin
select courses.courseNumber, restrictorID 
from restrictors 
left outer join courses on restrictors.courseNumber = courses.courseNumber;

end $$
delimiter ;


-- 15:
-- RestrictorList birtir upplýsingar um alla takmarkandi áfanga(restrictors) ásamt áföngum sem þeir takmarka.
-- Með öðrum orðum: Gemmér alla restrictors(undanfara, samfara) og þá áfanga sem þeir hafa takmarkandi áhrif á.
delimiter $$
drop procedure if exists RestrictorList $$

create procedure RestrictorList()
begin
	select restrictionID as 'undanfari, samfari', group_concat(courseNumber) as 'áhrif' from restrictions
			group by restrictorID;
end $$
delimiter ;
