from mysql.connector import MySQLConnection
from mysql.connector import Error
from config import *

class DbConnector:
    def __init__(self):
        self.status = ' '
        try:
            self.conn = MySQLConnection(user=USER,
										password=PASSWORD,
										host=HOST,
										database=DB,
										auth_plugin=AUTH)
            if self.conn.is_connected():
                self.status = 'connected'
            else:
                self.status = 'connection failed.'
        except Error as error:
            self.status = error

    def execute_function(self, func_header=None, argument_list=None):
        cursor = self.conn.cursor()
        try:
            if argument_list:
                func = func_header % argument_list
            else:
                func = func_header
            cursor.execute(func)
            result = cursor.fetchone()
        except Error as e:
            self.status = e
            result = None
        finally:
            cursor.close()
        return result[0]

    def execute_procedure(self, proc_name, argument_list=None):
        result_list = list()
        cursor = self.conn.cursor()
        try:
            if argument_list:
                cursor.callproc(proc_name, argument_list)
            else:
                cursor.callproc(proc_name)
            self.conn.commit()
            for result in cursor.stored_results():
                result_list = [list(elem) for elem in result.fetchall()]
        except Error as e:
            self.status = e
        finally:
            cursor.close()
        return result_list

#Student section


class StudentDB(DbConnector):
    def __init__(self):
        DbConnector.__init__(self)

    def new_student(self, first_name, last_name, date_of_birth, starting_on):
        new_id = 0
        result = self.execute_procedure('NewStudent', [first_name, last_name, date_of_birth, starting_on])
        if result:
            new_id = int(result[0][0])
        return new_id

    def single_student(self, student_id):
        result = self.execute_procedure('SingleStudent', [student_id])
        if result:
            return result[0]
        else:
            return list()

    def list_student(self):
        result = self.execute_procedure('StudentList')
        if result:
            return result[0]
        else:
            return list()

    def update_student(self, student_id, first_name, last_name, date_of_birth, starting_on):
        rows_affected = 0
        result = self.execute_procedure('UpdateStudent', [student_id, first_name, last_name, date_of_birth, starting_on])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

    def delete_student(self, student_id):
        rows_affected = 0
        result = self.execute_procedure('DeleteStudents', [student_id])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

#School section				

class SchoolDB(DbConnector):
    def __init__(self):
        DbConnector.__init__(self)

    def new_school(self, school_name):
        new_id = 0
        result = self.execute_procedure('NewSchool', [school_name])
        if result:
            new_id = int(result[0][0])
        return new_id

    def single_school(self, school_id):
        result = self.execute_procedure('SingleSchool', [school_id])
        if result:
            return result[0]
        else:
            return list()
	
    def list_school(self):
        result = self.execute_procedure('SchoolList')
        if result:
            return result[0]
        else:
            return list()

    def update_school(self, school_id, school_name):
        rows_affected = 0
        result = self.execute_procedure('UpdateSchool', [school_id, school_name])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

    def delete_school(self, school_id):
        rows_affected = 0
        result = self.execute_procedure('DeleteSchool', [school_id])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

#Áfangar section

class CourseDB(DbConnector):
    def __init__(self):
        DbConnector.__init__(self)

    def new_course(self, course_number, course_name, course_credits):
        new_id = 0
        result = self.execute_procedure('NewCourse', [course_number, course_name, course_credits])
        if result:
            new_id = int(result[0][0])
        return new_id

    def single_course(self, course_number):
        result = self.execute_procedure('SingleCourse', [course_number])
        if result:
            return result[0]
        else:
            return list()

    def list_course(self):
        result = self.execute_procedure('CourseList')
        if result:
            return result[0]
        else:
            return list()

    def update_course(self, course_number, course_name, course_credits):
        rows_affected = 0
        result = self.execute_procedure('UpdateCourse', [course_number, course_name, course_credits])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

    def delete_course(self, course_number):
        rows_affected = 0
        result = self.execute_procedure('DeleteCourse', [course_number])
        if result:
            rows_affected = int(result[0][0])
        return rows_affected

#Hér er fall sem keyrir sql function
    def execute_sql_procedure(self, function_name, parameters=None):
        returns = []
        try:
            cursor = self.conn.cursor(prepared=True)
            if parameters:
                cursor.execute(function_name, parameters)
            else:
                cursor.execute(function_name)
            
            returns = cursor.fetchone()
            cursor.close()
        except Error as error:
            self.status = error
            returns.append(None)
        finally:
            return returns[0]
#Fall sem keyrir sql SP
    def execute_sql_procedure(self, the_query, parameters=None):
        results = []
        try:
            cursor = self.conn.sursor()
            if parameters:
                print(the_query)
                cursor.callproc(the_query, parameters)
            else:
                cursor.callproc(the_query)
            
            self.conn.commit()

            for result in cursor.stored_results():
                results = result.fetchall()
        except Error as error:
            self.status = error
        finally:
            return results

#Nota tæknilega séð ekki síðustu 2 function en átti þetta hjá mér og langaði að bæta við.

