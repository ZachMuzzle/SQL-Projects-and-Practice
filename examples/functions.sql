-- FUNCTIONS
CREATE OR REPLACE FUNCTION show_description
(i_course_no course.course_no%type) -- creates a variable with course.course_no paramaters
return varchar2
as
v_description varchar2(50);
BEGIN
    SELECT description
    into v_description
    from course
    where i_course_no = course_no;
    return v_description;
EXCEPTION
    WHEN NO_DATA_FOUND
    then 
    return ('The course is not in the database');
    when others
    then
    return('Error in running show_description');
end;
/

-- Calls show_descripton with input of a number for course_no and returns the description.
set SERVEROUT on;
declare
    v_description varchar2(50);
begin 
    v_description := show_description(&sv_cnumber);
    dbms_output.put_line(v_description);
end;