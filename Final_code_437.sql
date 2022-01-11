-- Build tables

-- REGIONS TABLE
CREATE TABLE REGIONS 
(
  REGION_ID NUMBER NOT NULL 
, REGION_NAME VARCHAR2(25) 
, CREATED_BY VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_BY VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT REG_ID_PK PRIMARY KEY 
  (
    REGION_ID 
  )
  ENABLE 
);

-- COUNTRIES TABLE

CREATE TABLE countries (
    country_id    CHAR(2) NOT NULL,
    country_name  VARCHAR2(40),
    region_id     NUMBER,
    created_by    VARCHAR2(30),
    created_date  DATE,
    updated_by    VARCHAR(30),
    updated_date  DATE,
    CONSTRAINT country_c_id_pk PRIMARY KEY ( country_id ) ENABLE
);

ALTER TABLE countries
    ADD CONSTRAINT countr_reg_fk FOREIGN KEY ( region_id )
        REFERENCES regions ( region_id )
    ENABLE;
    
-- LOCATIONS TABLE
CREATE TABLE LOCATIONS 
(
  LOCATION_ID NUMBER(4) NOT NULL 
, STREET_ADDRESS VARCHAR2(40) 
, POSTAL_CODE VARCHAR2(12) 
, CITY VARCHAR2(30) NOT NULL 
, STATE_PROVINCE VARCHAR2(25) 
, COUNTRY_ID CHAR(2) 
, CREATED_BY VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_BY VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT LOC_ID_PK PRIMARY KEY 
  (
    LOCATION_ID 
  )
  ENABLE
  
);

CREATE INDEX LOC_CITY_IX ON LOCATIONS (CITY ASC);

CREATE INDEX LOC_COUNTRY_IX ON LOCATIONS (COUNTRY_ID ASC);

CREATE INDEX LOC_STATE_PROVINCE_IX ON LOCATIONS (STATE_PROVINCE ASC);

ALTER TABLE LOCATIONS
ADD CONSTRAINT LOC_C_ID_FK FOREIGN KEY
(
  COUNTRY_ID 
)
REFERENCES COUNTRIES
(
  COUNTRY_ID 
)
ENABLE;
-- JOBS TABLE

CREATE TABLE JOBS 
(
JOB_ID VARCHAR2(10) NOT NULL,
JOB_TITLE VARCHAR2(35) NOT NULL,
MIN_SALARY NUMBER(6),
MAX_SALARY NUMBER(6),
CREATED_BY VARCHAR2(30),
CREATED_DATE DATE,
UPDATED_BY VARCHAR2(30),
UPDATED_DATE DATE,
CONSTRAINT JOB_ID_PK PRIMARY KEY
(
JOB_ID
)
ENABLE
);
-- EMPLOYEES TABLE
CREATE TABLE EMPLOYEES 
(
  EMPLOYEE_ID NUMBER(6) NOT NULL 
, FIRST_NAME VARCHAR2(20) 
, LAST_NAME VARCHAR2(25) NOT NULL 
, EMAIL VARCHAR2(25) NOT NULL 
, PHONE_NUMBER VARCHAR2(20) 
, CREATED_BY VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_BY VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT EMP_EMP_ID_PK PRIMARY KEY 
  (
    EMPLOYEE_ID 
  )
  ENABLE 
);

CREATE INDEX EMP_NAME_IX ON EMPLOYEES (FIRST_NAME ASC, LAST_NAME ASC);

ALTER TABLE EMPLOYEES
ADD CONSTRAINT EMP_EMAIL_UK UNIQUE 
(
  EMAIL 
)
ENABLE;
-- DEPARTMENTS TABLE

CREATE TABLE DEPARTMENTS 
(
DEPARTMENT_ID NUMBER(4) NOT NULL,
DEPARTMENT_NAME VARCHAR2(30) NOT NULL,
MANAGER_ID NUMBER(6),
LOCATION_ID NUMBER(4),
CREATED_BY VARCHAR2(30),
CREATED_DATE DATE,
UPDATED_BY VARCHAR2(30),
UPDATED_DATE DATE,
CONSTRAINT DEPT_ID_PK PRIMARY KEY 
(
DEPARTMENT_ID 
)
ENABLE
);

CREATE INDEX DEPT_LOCATION_IX ON DEPARTMENTS (LOCATION_ID ASC);

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT DEPT_LOC_FK FOREIGN KEY 
(
LOCATION_ID
)
REFERENCES LOCATIONS
(
LOCATION_ID
)
ENABLE;

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT DEPT_MGR_FK FOREIGN KEY
(
MANAGER_ID
)
REFERENCES  EMPLOYEES
(
EMPLOYEE_ID
)
ENABLE;

-- EMPLOYMENT TABLE

CREATE TABLE EMPLOYMENT
(
EMPLOYMENT_ID NUMBER(9) NOT NULL,
EMPLOYEE_ID NUMBER(6) NOT NULL,
JOB_ID VARCHAR2(10) NOT NULL,
DEPARTMENT_ID NUMBER(4) NOT NULL,
CREATED_BY VARCHAR2(30),
CREATED_DATE DATE,
UPDATED_BY VARCHAR2(30),
UPDATED_DATE DATE,
CONSTRAINT EMPLOYMENT_PK PRIMARY KEY
(
EMPLOYMENT_ID
)
ENABLE
);

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK1 FOREIGN KEY
(
EMPLOYEE_ID
)
REFERENCES EMPLOYEES
(EMPLOYEE_ID) ENABLE;

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK2 FOREIGN KEY
( 
JOB_ID
)
REFERENCES JOBS
(JOB_ID) ENABLE;

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK3 FOREIGN KEY
(
DEPARTMENT_ID
)
REFERENCES DEPARTMENTS
(DEPARTMENT_ID) ENABLE;

-- EMPLOYMENT_PAY TABLE
CREATE TABLE EMPLOYMENT_PAY 
(
  EMPLOYMENT_ID NUMBER(9) NOT NULL 
, START_DATE DATE NOT NULL 
, SALARY NUMBER(8,2) 
, COMMISSION_PCT NUMBER(2,2) 
, CREATED_BY VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_BY VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT EMPLOYMENT_PAY_PK PRIMARY KEY 
  (
    START_DATE 
  , EMPLOYMENT_ID 
  )
  ENABLE 
);

ALTER TABLE EMPLOYMENT_PAY
ADD CONSTRAINT EMPLOYMENT_PAY_FK1 FOREIGN KEY
(
  EMPLOYMENT_ID 
)
REFERENCES EMPLOYMENT
(
  EMPLOYMENT_ID 
)
ENABLE;


-- EMPLOYEE SEQUENCE
DECLARE 
    v_start_value NUMBER(9);
    v_sql varchar2(2000);
BEGIN
    select
        nvl(MAX(EMPLOYEE_ID), 0) + 1
    INTO v_start_value
    FROM employees;
    v_sql := 'CREATE SEQUENCE EMPLOYEES_SEQ START WITH ' || v_start_value;
    EXECUTE IMMEDIATE v_sql;
END;
/
-- insert trigger for employees
CREATE OR REPLACE TRIGGER TRG_EMPLOYEES_PK BEFORE
    INSERT OR UPDATE ON EMPLOYEES
    FOR EACH ROW
BEGIN
    << column_sequences >> BEGIN
    if inserting THEN
        SELECT 
        EMPLOYEES_SEQ.NEXTVAL
        INTO :new.employee_id
        from
        sys.dual;
    end if;
    
    if updating then
        :new.employee_id := :old.employee_id;
    end if;
    end column_sequences;
end;
/
--employment sequence
DECLARE 
    v_start_value NUMBER(9);
    v_sql varchar2(2000);
BEGIN
    select
        nvl(MAX(employment_id), 0) + 1
    INTO v_start_value
    FROM employment;
    v_sql := 'CREATE SEQUENCE EMPLOYMENT_SEQ START WITH ' || v_start_value;
    EXECUTE IMMEDIATE v_sql;
END;
/
--EMPOLYMENT TRIGGER
CREATE OR REPLACE TRIGGER TRG_EMPLOYMENT_PK BEFORE
    INSERT OR UPDATE ON EMPLOYMENT
    FOR EACH ROW
BEGIN
    << column_sequences >> BEGIN
    if inserting THEN
        SELECT 
        EMPLOYMENT_SEQ.NEXTVAL
        INTO :new.employment_id
        from
        sys.dual;
    end if;
    
    if updating then
        :new.employment_id := :old.employment_id;
    end if;
    end column_sequences;
end;
/
-- create procedure
SET serveroutput on;
CREATE OR REPLACE PROCEDURE SECURE_ROWS
as
output varchar2(20);

BEGIN
SELECT CASE
         WHEN SYSDATE NOT BETWEEN TRUNC( SYSDATE ) + INTERVAL '07:00' HOUR TO MINUTE
                          AND TRUNC( SYSDATE ) + INTERVAL '18:00' HOUR TO MINUTE
         THEN 'Is between 7am and 6pm'
       END into output
FROM   DUAL;
EXCEPTION
WHEN OTHERS
THEN raise_application_error(-20005,'Time is not between 7am and 6pm');
end;
/
--execute secure_rows(); -- testing

-- triggers for update and created by
-- TRG_COUNTRIES_FP
CREATE OR REPLACE TRIGGER TRG_COUNTRIES_FP before
    INSERT OR UPDATE on COUNTRIES
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
--TRG_DEPARTMENTS_FP
CREATE OR REPLACE TRIGGER TRG_DEPARTMENTS_FP before
    INSERT OR UPDATE on DEPARTMENTS
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
-- EMPLOYEES
CREATE OR REPLACE TRIGGER TRG_EMPLOYEES_FP before
    INSERT OR UPDATE on EMPLOYEES
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
--EMPLOYMENT
CREATE OR REPLACE TRIGGER TRG_EMPLOYMENT_FP before
    INSERT OR UPDATE on EMPLOYMENT
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
--EMPLOYMENT_PAY
CREATE OR REPLACE TRIGGER TRG_EMPLOYMENT_PAY_FP before
    INSERT OR UPDATE on EMPLOYMENT_PAY
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
-- JOBS
CREATE OR REPLACE TRIGGER TRG_JOBS_FP before
    INSERT OR UPDATE on JOBS
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
-- LOCATIONS
CREATE OR REPLACE TRIGGER TRG_LOCATIONS_FP before
    INSERT OR UPDATE on LOCATIONS
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
--REGIONS
CREATE OR REPLACE TRIGGER TRG_REGIONS_FP before
    INSERT OR UPDATE on REGIONS
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.updated_by := user;
    :new.updated_date := sysdate;
END;
/
--secure_rows triggers ## not sure if correct
CREATE OR REPLACE TRIGGER TRG_COUNTRIES_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON COUNTRIES 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
--departments
CREATE OR REPLACE TRIGGER TRG_DEPARTMENTS_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON DEPARTMENTS 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
--employees
CREATE OR REPLACE TRIGGER TRG_employees_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON employees 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
-- employment
CREATE OR REPLACE TRIGGER TRG_employment_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON employment 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
-- employment_pay
CREATE OR REPLACE TRIGGER TRG_employment_pay_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON employment_pay 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
-- JOBS
CREATE OR REPLACE TRIGGER TRG_jobs_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON jobs 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
-- locations
CREATE OR REPLACE TRIGGER TRG_locations_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON locations 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/
-- regions
CREATE OR REPLACE TRIGGER TRG_regions_SECURE_ROWS BEFORE
INSERT OR UPDATE OR DELETE ON regions 
FOR EACH ROW
BEGIN 
secure_rows();
end;
/

-- VIEWS
-- V_EMPLOYEE
CREATE OR REPLACE VIEW V_EMPLOYEE as
select 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    emp.email,
    emp.phone_number,
    last_day(emp_p.start_date) as hire_date
    from employees emp--,employment empl,employment_pay emp_p
    inner join employment empl on emp.employee_id = empl.employee_id
    inner join employment_pay emp_p on empl.employment_id = emp_p.employment_id;
    /
--V_EMPLOYMENT
CREATE OR REPLACE VIEW V_EMPLOYMENT as
select
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    emp.email,
    emp.phone_number,
    emp_p.employment_id,
    emp_p.start_date,
    ADD_MONTHS(emp_p.start_date,+12) as END_DATE,
    emp_p.salary,
    emp_p.commission_pct
    from employees emp
    inner join employment empl on emp.employee_id = empl.employee_id
    inner join employment_pay emp_p on empl.employment_id = emp_p.employment_id;
   / 
-- Four Business Rules
-- EMPLOYMENT_PAY.SALARY
CREATE OR REPLACE TRIGGER TRG_EMPLOYMENT_PAY_CHK BEFORE INSERT OR UPDATE
of salary on EMPLOYMENT_PAY
FOR EACH ROW

DECLARE
min_sal jobs.min_salary%type;
max_sal jobs.max_salary%type;
begin
for c in (select min_salary, max_salary into min_sal, max_sal from jobs) -- without cursor can be done with cursor like in ADVANCE_CURSOR.sql

loop

min_sal := c.min_salary;
max_sal := c.max_salary;

end loop;
--where job_id = :new.job_id;
if :new.salary > max_sal or :new.salary < min_sal then
    raise_application_error(-20003, 'Salary is not within min and max salary');
    end if;
end;
/
----
--Locations.postal_code
CREATE OR REPLACE TRIGGER TRG_LOCATIONS_CHK BEFORE 
INSERT OR UPDATE OF postal_code,country_id on locations
FOR EACH ROW 
--when (REGEXP_LIKE(new.postal_code,'^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHIJKLMNPRSTVWXYZ][-]?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$'))
declare test_exp EXCEPTION;
BEGIN

IF NOT REGEXP_LIKE (:NEW.POSTAL_CODE, '^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHIJKLMNPRSTVWXYZ][-]?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$') AND (:NEW.country_id = 'CA')
THEN 
raise test_exp;
end if;

IF NOT REGEXP_LIKE(:NEW.POSTAL_CODE, '([[:digit:]]{5})(-[[:digit:]]{4})?$') AND (:NEW.country_id = 'US')
THEN
raise test_exp;
end if;

EXCEPTION
when test_exp then
raise_application_error(-20000,'Postal code is not correct format');
end;
/
-- Job min salary
CREATE OR REPLACE TRIGGER TRG_JOBS_CHK BEFORE INSERT OR UPDATE 
ON JOBS
FOR EACH ROW
declare 
--failed_check varchar(20);
min_sal jobs.min_salary%type;
max_sal jobs.max_salary%type;

BEGIN

if (:new.min_salary >= :new.max_salary) then 
raise_application_error(-20001,'Min_salary is not smaller than max');
end if;
end;
/
