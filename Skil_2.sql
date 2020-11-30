use progresstracker_v6;
/* 1:
	Smíðið trigger fyrir insert into Restrictors skipunina. 
	Triggernum er ætlað að koma í veg fyrir að einhver áfangi sé undanfari eða samfari síns sjálfs. 
	með öðrum orðum séu courseNumber og restrictorID með sama innihald þá stoppar triggerinn þetta með
	því að kasta villu og birta villuboð.
	Dæmi um insert sem triggerinn á að stoppa: insert into Restrictors values('GSF2B3U','GSF2B3U',1);
*/
delimiter $$
drop trigger if exists unique_restrictors$$
create trigger unique_restrictors
before insert on Restrictors
for each row
begin
	declare msg varchar(300);
    
	if(new.courseNumber = new.restrictorID) then
    set msg = 'coursenumber og restrictor geta ekki verið alveg eins!';
    signal sqlstate '12000' set message_text = msg;
	end if;
end$$
delimiter ;

-- 2:
-- Skrifið samskonar trigger fyrir update Restrictors skipunina.
delimiter $$
drop trigger if exists update_restrictors$$
create trigger update_restrictor
before update on Restrictors
for each row
begin
	declare msg varchar(300);
    
	if(new.courseNumber = new.restrictorID) then
    set msg = 'coursenumber og restrictor geta ekki verið alveg eins!';
    signal sqlstate '12333' set message_text = msg;
	end if;
end$$
delimiter ;

/*
	3:
	Skrifið stored procedure sem leggur saman allar einingar sem nemandinn hefur lokið.
    Birta skal fullt nafn nemanda, heiti námsbrautar og fjölda lokinna eininga(
	Aðeins skal velja staðinn áfanga. passed = true
*/
delimiter $$
drop procedure if exists show_studentCredits $$

create procedure show_studentCredits(param_studentID int)
begin

	SELECT 
	concat(students.firstName, " ", students.lastName) as "Name",
    SUM(Courses.courseCredits) AS "Credits",
    Tracks.trackName,
    Courses.courseName
	FROM  students
    INNER JOIN registration ON registration.studentID = Students.studentID
	INNER JOIN Courses ON courses.courseNumber = registration.courseNumber
    INNER JOIN Tracks ON tracks.trackID = registration.trackID
	WHERE students.studentID = param_studentID
    AND registration.passed = 1;
	
end$$
call show_studentCredits(1)$$
delimiter ;

/*
	4:
	Skrifið 3 stored procedure-a:
    AddStudent()
    AddMandatoryCourses()
    Hugmyndin er að þegar AddStudent hefur insertað í Students töfluna þá kallar hann á AddMandatoryCourses() sem skráir alla
    skylduáfanga á nemandann.
    Að endingu skrifið þið stored procedure-inn StudentRegistration() sem nota skal við sjálfstæða skráningu áfanga nemandans.
*/
drop procedure if exists AddStudent;

delimiter &&
create procedure AddStudent(first_name varchar(55), last_name varchar(55), date_of_birth date, track_id int, semester_id int)
begin
	declare new_student_id int;
    
    insert into Students(firstName,lastName,dob,startSemester)values(first_name, last_name, date_of_birth, semester_id);
    set new_student_id = last_insert_id();
end &&
delimiter ;
    
delimiter €€
create procedure AddMandatoryCourses(student_id int, track_id int, first_semester_id int)
begin
	insert into registration(studentID,trackID,courseNumber,registrationDate,passed,semesterID)
	select student_id, track_id, TrackCourses.courseNumber, date(now()),false, first_semester_id + (TrackCourses.semester - 1)
	from TrackCourses
	where trackID = track_id and mandatory = true;
	select row_count() as Courses_Added;
end €€
delimiter;
								     
call AddMandatoryCourses(1,7,'2020-11-30',6); select * from registration;								    
								    
								     
drop procedure if exists StudentRegistration $$
    
create procedure StudentRegistration(in varStudentID int, in varTrackID int, in varCourseNumber char(10), in varDate date, in varPassed bool, in varSemester int)
begin
	insert into Registration(studentID,trackID,courseNumber,registrationDate,passed,semesterID)
	values(varStudentID,varTrackID,varCourseNumber,varDate,varPassed,varSemester);
end $$
delimiter ;								     
    
call StudentRegistration(1,7,'FORR302','2020-11-30',false,6);
