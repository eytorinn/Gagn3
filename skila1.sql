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

create procedure SingleCourse()
begin
	select * from courses where courseNumber = "STÆ303";
end $$
delimiter ;


-- 3:
-- Nýskráið áfanga í gagnagrunninn.
-- Það þarf að skrá áfanganúmerið, áfangaheitið og einingafjöldann
delimiter $$
drop procedure if exists NewCourse $$

create procedure NewCourse()
begin
	insert into courses(courseNumber, áfangaheitið, courseCredits) values("RIG304", "Rigningafræði", 5);
end $$
delimiter ;


-- 4:
-- Skrifið Stored Procedure sem uppfærir áfanga
-- Uppfærið réttan kúrs með því að senda courseNumber sem færibreytu.
-- row_count() fallið er hér notað til að birta fjölda raða sem voru uppfærðar.
delimiter $$
drop procedure if exists UpdateCourse $$

create procedure UpdateCourse()
begin
	UPDATE courses
SET 
    courseNames = "Rigningafræði"
WHERE
    CourseNumber = "RIG304";
end $$
delimiter ;


-- 5:
-- Skrifið SP sem eyðir áfanga.
-- ATH: Ef verið er að nota áfangann einhversstaðar(sé hann skráður á TrackCourses töfluna) þá má EKKI eyða honum.
-- Sé hins vegar hvergi verið að nota hann má eyða honum úr bæði Courses og Restrictor töflunum.
delimiter $$
drop procedure if exists DeleteCourse $$

create procedure DeleteCourse()
begin
	delete from courses
	where not exists
		(select courseNumber from trackcourses where trackcourses.courseNumber = courses.courseNumber);
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
    
create function TotalTrackCredits()
returns int
begin
	select courses.courseNumber, courses.courseCredits
    from courses
    inner join TrackCourses on courses.courseNumber, TrackCourses.courseNumber;
end $$
delimiter ;


-- 8: 
-- Fallið skilar heildarfjölda áfanga sem eru í boði á ákveðinni námsleið
delimiter $$
drop function if exists TotalNumberOfTrackCourses $$
    
create function TotalNumberOfTrackCourses()
returns int
begin
	return (select count(trackID) 
				from trackcourses
				where trackID = @trackID);
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
-- Fallið reiknar út og skilar aldri ákveðins nemanda
delimiter $$
drop function if exists StudentAge $$
    
create function StudentAge()
returns int
begin
	declare age int;
	set age = 0;

	select timestampdiff(year, Studs.dob, curdate()) into age
	from Students
	where studentID = studID;

	return age;
end $$
delimiter ;

-- 12:
-- Fallið skilar fjölda þeirra eininga sem nemandinn hefur tekið(lokið)
delimiter $$
drop function if exists StudentCredits $$
    
create function StudentCredits()
returns int
begin
	declare units int;
	set units = 0;

	select count(passed) into units 
	from Registration
	where  studentID = studentID;

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
	-- kóði hér...
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
	-- kóði hér...
end $$
delimiter ;
