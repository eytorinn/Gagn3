use ProgressTracker_V6;

delimiter €€

drop procedure if exists NewStudent €€
drop procedure if exists SingleStudent €€
drop procedure if exists StudentList €€
drop procedure if exists UpdateStudent €€
drop procedure if exists DeleteStudent €€

drop procedure if exists NewSchool €€
drop procedure if exists SingleSchool €€
drop procedure if exists SchoolList €€
drop procedure if exists UpdateSchool €€
drop procedure if exists DeleteSchool €€

drop procedure if exists NewCourse;
drop procedure if exists SingleCourse €€
drop procedure if exists CourseList €€
drop procedure if exists UpdateCourse €€
drop procedure if exists DeleteCourse €€

-- ======================================= - oo0oo - ======================================= --
create procedure NewStudent(first_name varchar(55), last_name varchar(55), date_of_birth date, starting_on int)
begin
	insert into Students(firstName,lastName,dob,startSemester)
    values(first_name,last_name,date_of_birth,starting_on);
    
    select last_insert_id();
end €€

create procedure SingleStudent(student_id int)
begin
	select studentID,concat(firstName,' ',lastName) as student_name,dob, startSemester
    from Students where studentID = student_id;
end €€

create procedure StudentList()
begin
	select studentID,concat(firstName,' ',lastName) as student_name
    from Students order by firstName,LastName;
end €€

create procedure UpdateStudent(student_id int, f_name varchar(55), l_name varchar(55), d_o_b date, starting_on int)
begin
	update Students set firstName = f_name,lastName = l_name, dob = d_o_b,startSemester = starting_on
    where studentID = student_id;
end €€

create procedure DeleteStudent(student_id int)
begin
	if not exists (select registrationID from Registration where studentID = student_id) then
		delete from Students where studentID = student_id;
	end if;
    
    select row_count();
end €€

-- ======================================= - oo0oo - ======================================= --
create procedure NewSchool(school_name varchar(75))
begin
	insert into Schools(schoolName)values(school_name);
    
    select last_insert_id();
end €€

create procedure SingleSchool(school_id int)
begin
	select schoolID, schoolName
    from Schools
    where schooldID = school_id;
end €€

create procedure SchoolList()
begin
	select schoolID, schoolName
    from Schools order by schoolName;
end €€

create procedure UpdateSchool(school_id int, school_name varchar(75))
begin
	update Schools set schoolName = school_name
    where schoolID = school_id;
end €€

create procedure DeleteSchool(school_id int)
begin
	if not exists (select divisionID from Divisions where schoolID = school_id) then
		delete from Schools where schoolID = school_id;
	end if;
    
    select row_count();
end €€

-- ======================================= - oo0oo - ======================================= --
delimiter €€


create procedure NewCourse(course_number char(15), course_name varchar(75), course_credits int)
begin
	insert into Courses(courseNumber,courseName,courseCredits)
    value(course_number, course_name, course_credits);
    
    select row_count();
end €€

create procedure SingleCourse(course_number char(15))
begin
	select courseNumber,courseName,courseCredits
    from Courses
    where courseNumber = course_number;
end €€

create procedure CourseList()
begin
	select courseNumber, courseCredits
    from Courses
    order by CourseNumber;
end €€

create procedure UpdateCourse(course_number char(15), course_name varchar(75), course_credits int)
begin
	update Courses set courseName = course_name, courseCredits = course_credits
    where courseNumber = course_number;
end €€

create procedure DeleteCourse(course_number char(15))
begin
	if not exists (select trackID from TrackCourses where courseNumber = course_number) then
		delete from Courses where courseNumber = course_number;
	end if;
    
    select row_count();
end €€

delimiter ;
