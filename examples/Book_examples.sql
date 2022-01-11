set SERVEROUTPUT ON;
declare e_test_expection EXCEPTION;
BEGIN
DBMS_OUTPUT.PUT_LINE ('Expection was not triggered');
RAISE e_test_expection;

EXCEPTION

WHEN e_test_expection then RAISE_APPLICATION_ERROR(-20001, 'Error happened!');
END;
/
set SERVEROUT ON;
<<out_block>>
DECLARE 
e_exp1 EXCEPTION;
e_exp2 EXCEPTION;

BEGIN
<<inner_block>>
BEGIN
RAISE e_exp1;
EXCEPTION WHEN e_exp1 then RAISE e_exp2;
WHEN e_exp2 THEN  DBMS_OUTPUT.PUT_LINE('An error happened in inner block'); 
end;

EXCEPTION
when e_exp2
then DBMS_OUTPUT.PUT_LINE('ERROR WITH PROGRAM');
end;
/
-----------------------------------------CURSOR PRACTICE
SET SERVEROUT ON;
DECLARE 
v_first_name VARCHAR2(35);
v_last_name VARCHAR2(35);

BEGIN
SELECT first_name, last_name 
INTO v_first_name, v_last_name
FROM STUDENT
WHERE STUDENT_ID = 123;
DBMS_OUTPUT.PUT_LINE('NAME:' || v_first_name|| ' ' || v_last_name);

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(' NO STUDENT WITH ID 123!');
END;
/
-- CURSOR_ADVANCE
SET SERVEROUT ON;
DECLARE
CURSOR c_student is
SELECT first_name, last_name
from student
WHERE rownum <=5;
vr_student c_student%ROWTYPE;
BEGIN
OPEN c_student;
LOOP
FETCH c_student into vr_student;
EXIT WHEN c_student%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('Student name: ' || vr_student.first_name || ' ' || vr_student.last_name);
END LOOP;
CLOSE c_student;
end;
/
-- IMPLICT CURSOR USED FOR INSERT, UPDATE OR DELETE DML
SET SERVEROUT ON;
DECLARE 
total_rows number;
BEGIN
UPDATE STUDENT
set student_id = student_id + 1;
if sql%notfound then
DBMS_OUTPUT.PUT_LINE('NO ID FOUND');
ELSIF sql%found then
total_rows := sql%rowcount;
DBMS_OUTPUT.PUT_LINE(total_rows || ' student ids selected');
END IF;
END;
/
-- SHOWS ALL STUDENTS
SET SERVEROUT ON;
declare 
cursor c_stu is 
select first_name, last_name
from student;
vr_stu c_stu%ROWTYPE;
begin
open c_stu;
loop
fetch 
c_stu into vr_stu;
EXIT when c_stu%NOTFOUND;
DBMS_OUTPUT.PUT_LINE(vr_stu.first_name || ' ' || vr_stu.last_name);
END loop;
close c_stu;
end;
/
-- USE FOR CURSOR
SET SERVEROUT ON;
declare 
cursor c_stu is 
select student_id, first_name, last_name
from student
where student_id < 250;
BEGIN
FOR r_stu in c_stu 
LOOP
DBMS_OUTPUT.PUT_LINE('STU ID: ' || r_stu.student_id || ' ' || 'First_name: ' || r_stu.first_name || ' ' || 'Last name: ' || r_stu.last_name);
END LOOP;
END;
/

-- NEST CURSOR LOOP for student id and course they are enrolled in
SET SERVEROUT ON
DECLARE
    v_sid student.student_id%TYPE; -- get type of student student id and put towards v_sid
    CURSOR c_stu is -- cursor for student
    SELECT student_id, first_name, last_name 
    from student
    where student_id < 110;
    CURSOR c_course is -- cursor for course
    select c.course_no, c.description
    from course c, section s, enrollment e
    where c.course_no = s.course_no and s.section_id = e.section_id and e.student_id = v_sid;
    
BEGIN
    FOR r_stu in c_stu
    LOOP
        v_sid := r_stu.student_id;
        DBMS_OUTPUT.PUT_LINE(chr(10)); -- blank for space
        DBMS_OUTPUT.PUT_LINE('The Student ' || r_stu.student_id|| ' ' || r_stu.first_name|| ' ' || r_stu.last_name);
        DBMS_OUTPUT.PUT_LINE('Enrolled in: ');
        FOR r_course in c_course
        LOOP
        DBMS_OUTPUT.PUT_LINE(r_course.course_no|| ' ' || r_course.description);
        END LOOP;
    END LOOP;
END;