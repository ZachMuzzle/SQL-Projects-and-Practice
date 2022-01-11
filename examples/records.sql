-- RECORDS
SET SERVEROUTPUT ON;

DECLARE

course_rec course%ROWTYPE; -- works similar to %TYPE but just with rows now and not just one varaiable.
BEGIN 
SELECT *
INTO course_rec 
from course
where course_no = 25;

DBMS_OUTPUT.PUT_LINE('Course no is: ' || course_rec.course_no);
DBMS_OUTPUT.PUT_LINE('Course description: ' || course_rec.description);
DBMS_OUTPUT.PUT_LINE('Course prerequisite: ' || course_rec.prerequisite);
END;
/

-- record using cursor
DECLARE 
cursor student_cur is 
select first_name, last_name, registration_date
from student
where rownum <= 4;

student_rec student_cur%ROWTYPE;

BEGIN
OPEN student_cur;
LOOP
FETCH student_cur into student_rec;
EXIT WHEN student_cur%NOTFOUND;

DBMS_OUTPUT.PUT_LINE('Name: ' || student_rec.first_name || ' ' || student_rec.last_name);
DBMS_OUTPUT.PUT_LINE('Registration date: ' || to_char(student_rec.registration_date, 'MM/DD/YYYY')); -- converts date to string.
END LOOP;
END;
/
-- user defined record.

DECLARE TYPE time_rec_type is RECORD
(curr_date DATE,
 curr_day varchar(12),
 curr_time varchar(8) := '00:00:00');
 
time_rec TIME_REC_TYPE; -- record name record type

BEGIN
select sysdate
into time_rec.curr_date
from dual;

time_rec.curr_day := TO_CHAR(time_rec.curr_date, 'DAY');
time_rec.curr_time := TO_CHAR(time_rec.curr_date, 'HH24:MI:SS');

DBMS_OUTPUT.PUT_LINE('DATE: ' || to_char(time_rec.curr_date, 'MM/DD/YYYY HH24:MI:SS'));
DBMS_OUTPUT.PUT_LINE('DAY: ' || time_rec.curr_day);
DBMS_OUTPUT.PUT_LINE('TIME: ' || time_rec.curr_time);
END;
/
----------------------------------------------------- test multiple records
DECLARE
CURSOR course_curs IS
SELECT *
from course
where rownum < 2;

TYPE course_type IS RECORD
(course_no NUMBER(38)
 , description VARCHAR2(50)
 , cost NUMBER(9,2)
 , prerequisite NUMBER(9)
 , created_by varchar2(30)
 , created_date DATE
 , modified_by varchar2(30)
 , modified_date DATE);
 
 course_rec1 course%ROWTYPE; -- table based record
 course_rec2 course_curs%ROWTYPE; -- cursor based record
 course_rec3 course_type; -- user defined record
 
 BEGIN
 SELECT *
 INTO course_rec1
 from course
 where course_no = 10;
 
 -- populate cursor record
 open course_curs;
 loop
 fetch course_curs into course_rec2;
 EXIT when course_curs%NOTFOUND;
 END LOOP;
 
 -- assign course_rec2 to course_rec1 and course_rec3
 course_rec1 := course_rec2;
 course_rec3 := course_rec2;
 
 DBMS_OUTPUT.PUT_LINE(course_rec1.course_no|| ' - ' || course_rec1.description);
 DBMS_OUTPUT.PUT_LINE(course_rec2.course_no|| ' - ' || course_rec2.description);
 DBMS_OUTPUT.PUT_LINE(course_rec3.course_no|| ' - ' || course_rec3.description);

 END;
 /
 --------------------- nested records
 declare 
 type name_type is record
 (first_name varchar2(15),
  last_name varchar2(30));
  
  type person_type is record
  (name name_type,
  street varchar2(50),
  zip varchar2(5));
  
  person_rec person_type; -- call record user defined
  
  BEGIN 
  SELECT first_name, last_name, street_address,zip
  INTO person_rec.name.first_name, person_rec.name.last_name, person_rec.street, person_rec.zip
  from student
  --join zipcode using (zip)
  where rownum < 2;
  
  DBMS_OUTPUT.PUT_LINE('Name: '|| person_rec.name.first_name|| ' ' || person_rec.name.last_name); -- link name with last name record
  
  END;
  /
  
  --TAKE IN RECORD EXAMPLE
  
  DECLARE 
  TYPE last_name_type is TABLE OF student.last_name%type -- collection
  index BY PLS_INTEGER; 
  
  TYPE zip_info_type IS RECORD
  (zip VARCHAR2(5),
  last_name_tab last_name_type);
  
  CURSOR name_cur (p_zip varchar2) is
  select last_name
  from student
  where p_zip = zip; -- make sure p_zip is declared as same as zip or error will occur.
  
  zip_info_rec zip_info_type; -- call record
  v_zip varchar2(5) := '&sv_zip'; -- zip input
  v_index PLS_INTEGER := 0; -- start at zero
  
  BEGIN
  zip_info_rec.zip := v_zip;
  DBMS_OUTPUT.PUT_LINE('ZIP: ' || zip_info_rec.zip);
  
  FOR name_rec in name_cur(v_zip)
  LOOP
  v_index := v_index + 1;
  zip_info_rec.last_name_tab(v_index) := name_rec.last_name;
  
  DBMS_OUTPUT.PUT_LINE('NAME('||v_index||'): '||zip_info_rec.last_name_tab(v_index));
  END LOOP;
  END;
  /
  --COLLECTIONS WITH RECORDS
  DECLARE 
  CURSOR name_curr is
  SELECT FIRST_NAME, Last_name
  from student
  where rownum <= 4;
  
  type name_type is table of name_curr%ROWTYPE -- assosiative array collection
  INDEX BY PLS_INTEGER;
  
  name_tab name_type;
  v_index PLS_INTEGER := 0;
  
  BEGIN
  for name_rec in name_curr
  LOOP
  v_index := v_index + 1;
  
  name_tab(v_index).first_name := name_rec.first_name; -- first name
  name_tab(v_index).last_name := name_rec.last_name; -- last name
  
  DBMS_OUTPUT.PUT_LINE('First name('||v_index||'): '||name_tab(v_index).first_name);
  DBMS_OUTPUT.PUT_LINE('Last name('||v_index||'): '||name_tab(v_index).last_name);
  END LOOP;
  END;
  /
  -- COLLECTION AND RECORD USING USER DEFINED RECORD
  DECLARE
  CURSOR enroll_cur is 
  select first_name, last_name, count(*) total
  from student
  join enrollment using (student_id)
  group by first_name, last_name;
  
  type enroll_rec_type is RECORD
  (first_name varchar2(15),
   last_name varchar2(20),
   enrollments integer);
   
   type enroll_array_type is table of enroll_rec_type -- collection
   index by pls_integer;
   
   enroll_tab enroll_array_type; -- call type collection
   
   v_index INTEGER := 0;
   
   BEGIN
   for enroll_rec in enroll_cur
   LOOP
   v_index := v_index + 1;
   
   enroll_tab(v_index).first_name := enroll_rec.first_name;
   enroll_tab(v_index).last_name := enroll_rec.last_name;
   enroll_tab(v_index).enrollments := enroll_rec.total;
   
   if v_index <= 4
   then 
   DBMS_OUTPUT.PUT_LINE('First name('||v_index||'): '||enroll_tab(v_index).first_name);
   DBMS_OUTPUT.PUT_LINE('Last name('||v_index||'): '||enroll_tab(v_index).last_name);
   DBMS_OUTPUT.PUT_LINE('Enrollments('||v_index||'): '||enroll_tab(v_index).enrollments);
   DBMS_OUTPUT.PUT_LINE('------------------------------------');
   END IF;
   END LOOP;
   END;
  
  