
SET serveroutput on;
declare
--create or replace procedure less_six as
    cursor six_less_c
    is
        select course.course_no, course.description, section.Section_no, count(*) as CountOfEnrollment
            from course course, section section, enrollment enrollment
            where course.course_no = section.course_no AND enrollment.section_id = section.section_id
            group by course.course_no ,course.description, section.Section_no
        having count(enrollment.section_id) < 6;
    BEGIN
        FOR six_less_r IN six_less_c
        LOOP
            DBMS_OUTPUT.PUT_LINE(six_less_r.course_no|| ' ' || six_less_r.description 
            || ' ' || six_less_r.Section_no || ' ' || six_less_r.CountOfEnrollment);
        END LOOP;
    END;
    
    
EXECUTE less_six;