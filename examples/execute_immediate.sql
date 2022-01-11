
-- EXECUTE IMMEDIATE 
SET SERVEROUTPUT ON;

DECLARE
    
    sql_stmt varchar2(100);
    plsql_block varchar2(300);
    v_zip varchar2(5) := '11106';
    v_total_students NUMBER;
    v_new_zip varchar2(5);
    v_student_id NUMBER := 151;
    
BEGIN
    sql_stmt := ' CREATE TABLE MY_STUDENT' || 
    ' AS SELECT * FROM STUDENT WHERE zip = ' || v_zip;
    EXECUTE IMMEDIATE sql_stmt;
    
    -- select total number of records from my student table
    
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM my_STUDENT' INTO v_total_students;
    DBMS_OUTPUT.PUT_LINE('Students counted: ' || v_total_students);
    
    -- select current date and display it
    plsql_block := 'DECLARE '           ||
                    ' v_date DATE;'     ||
                    'begin'             ||
                    ' SELECT SYSDATE INTO V_DATE FROM DUAL; ' ||
                    'DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_date,
                                                        ''DD-MON-YYYY''));' ||
                    'END;';
    EXECUTE IMMEDIATE plsql_block;
    
    --update 
    sql_stmt := 'UPDATE my_student set zip=11105 where student_id =:1 ' || 'returning zip into :2';
    execute immediate sql_stmt using v_student_id returning into v_new_zip;
    dbms_output.put_line('New zip: ' || v_new_zip);
    END;
    /
    drop table my_student;
    /
    DECLARE
        sql_stmt varchar2(200);
        v_student_id NUMBER := &sv_student_id;
        v_first_name varchar2(20);
        v_last_name varchar2(20);
        
    BEGIN
        sql_stmt := 'SELECT first_name, last_name ' ||
                ' from student '                ||
                ' where student_id = :1 ' ;      -- :1 is a placeholder 
        EXECUTE IMMEDIATE sql_stmt
        INTO v_first_name, v_last_name
        using v_student_id;
        
        dbms_output.put_line('First name: ' || v_first_name);
        dbms_output.put_line('Last name: ' || v_last_name);
        end;
        /
DECLARE
    sql_stmt varchar2(300);
    v_student_id number := &sv_student_id;
    v_first_name varchar2(30);
    v_last_name varchar2(40);
    v_street varchar2(50);
    v_city varchar2(25);
    v_state varchar2(15);
    v_zip varchar2(10);
    
BEGIN

    sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address,' ||
                ' b.city, b.state, b.zip'     ||
                ' from student a, zipcode b ' ||
                ' where a.zip = b.zip and student_id = :1 '; --placeholder
    
    execute immediate sql_stmt
    into v_first_name, v_last_name,v_street, v_city, v_state,v_zip -- must match select statement in exact order.
    using v_student_id; -- use student_id input to find right user
    
    DBMS_OUTPUT.PUT_LINE('First name: ' || v_first_name);
    DBMS_OUTPUT.PUT_LINE('Last_name: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('STREET: ' || v_street);
    DBMS_OUTPUT.PUT_LINE('City: ' || v_city);
    DBMS_OUTPUT.PUT_LINE('State: ' || v_state);
    DBMS_OUTPUT.PUT_LINE('Zip: ' || v_zip);
    
    end;
/

DECLARE
    sql_stmt varchar2(300);
    v_id number := &sv_id;
    v_table_name varchar2(30) := '&sv_table_name';
    v_first_name varchar2(30);
    v_last_name varchar2(40);
    v_street varchar2(50);
    v_city varchar2(25);
    v_state varchar2(15);
    v_zip varchar2(10);
    
BEGIN

    sql_stmt := 'SELECT a.first_name, a.last_name, a.street_address,' ||
                ' b.city, b.state, b.zip'     ||
                ' from '||v_table_name||' a, zipcode b' ||
                ' where a.zip = b.zip' ||
                ' and '||v_table_name||'_id = :1';
    
    execute immediate sql_stmt
    into v_first_name, v_last_name,v_street, v_city, v_state,v_zip -- must match select statement in exact order.
    using v_id; -- use student_id input to find right user
    
    DBMS_OUTPUT.PUT_LINE('First name: ' || v_first_name);
    DBMS_OUTPUT.PUT_LINE('Last_name: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('STREET: ' || v_street);
    DBMS_OUTPUT.PUT_LINE('City: ' || v_city);
    DBMS_OUTPUT.PUT_LINE('State: ' || v_state);
    DBMS_OUTPUT.PUT_LINE('Zip: ' || v_zip);
    
    end;
                