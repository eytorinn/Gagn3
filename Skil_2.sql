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
    set msg = 'coursenumber og restrictor geta ekki verið alveg eins!!';
    signal sqlstate '12000' set message_text = msg;
	end if;
end$$
delimiter ;

-- 2:
-- Skrifið samskonar trigger fyrir update Restrictors skipunina.
delimiter $$
drop trigger if exists update_restrictors$$
create trigger update_restrictor
after update on Restrictors
for each row
begin
	declare msg varchar(300);
    
	if(new.courseNumber = new.restrictorID) then
    set msg = 'coursenumber og restrictor geta ekki verið alveg eins!!';
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
    
    call AddMandatoryCourses(new_student_id, track_id, semester_id);
    
    end &&
    delimiter ;

