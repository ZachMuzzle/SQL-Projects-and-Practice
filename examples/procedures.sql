-- PROCEDURES

CREATE OR REPLACE PROCEDURE discount
AS
    cursor c_group_discount
    IS
    SELECT distinct s.course_no, c.description -- distinct means no duplicates.
    from section s, course c, enrollment e
    where s.section_id = e.section_id
    and c.course_no = s.course_no
    group by s.course_no, c.description, e.section_id, s.section_id
    having count(*) >=8;
    
BEGIN
    for r_group_discount in c_group_discount
    loop
        update course
            set cost = cost*.95 
        where course_no = r_group_discount.course_no;
        DBMS_OUTPUT.PUT_LINE('A 5% discount has been given to '||r_group_discount.course_no|| ' ' || r_group_discount.description);
        END loop;
    end;
    /
    
CREATE OR REPLACE PROCEDURE find_sname
(i_student_id in number,
 o_first_name out varchar2,
 o_last_name out varchar2)
 as
 BEGIN
    SELECT FIRST_NAME,LAST_NAME 
    into o_first_name, o_last_name
    from student
    where student_id = i_student_id;
EXCEPTION
    when others
    then
    dbms_output.PUT_LINE('Error in finding student_id');
end find_sname;
/

DECLARE
    v_local_first_name student.first_name%TYPE;
    v_local_last_name student.last_name%TYPE;
BEGIN
    find_sname
        (145,v_local_first_name,v_local_last_name);
        DBMS_OUTPUT.PUT_LINE('Student 145 name is '|| v_local_first_name|| ' ' || v_local_last_name);
END;
