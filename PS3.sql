---------------------------------- Delete Foreign Keys for COURSE table
ALTER TABLE COURSE
DROP CONSTRAINT CRSE_CRSE_FK;
/
-------------------------- Delete foreign keys for enrollment tables
ALTER TABLE ENROLLMENT
DROP CONSTRAINT ENR_SECT_FK;
/
ALTER TABLE ENROLLMENT
DROP CONSTRAINT ENR_STU_FK;
/

----------------------- delete foreign keys for section table
ALTER TABLE SECTION
DROP CONSTRAINT SECT_CRSE_FK;
/
-- Delete primary keys for tables

------------------------------------- course
ALTER TABLE COURSE
DROP CONSTRAINT CRSE_PK;
/

---------------------------------- section
ALTER TABLE SECTION
DROP CONSTRAINT SECT_PK;
/

----------------------------- enrollment
ALTER TABLE ENROLLMENT
DROP CONSTRAINT ENR_PK;
/
------------------------------ STUDENT
ALTER TABLE STUDENT
DROP CONSTRAINT STU_PK;
/
------------------------------------------ create school table
CREATE TABLE SCHOOL 
(
  SCHOOL_ID NUMBER NOT NULL 
, SCHOOL_NAME VARCHAR2(30) 
, CREATED_BY VARCHAR2(30) NOT NULL 
, CREATED_DATE DATE NOT NULL 
, MODIFIED_BY VARCHAR2(30) NOT NULL 
, MODIFIED_DATE DATE NOT NULL 
, CONSTRAINT SCHOOL_PK PRIMARY KEY 
  (
    SCHOOL_ID 
  )
  ENABLE 
);
/

-- insert 1 for school_ID
INSERT INTO SCHOOL (school_id,school_name,created_by,created_date,modified_by,modified_date)
VALUES(1,'UD','ZMUZZLEM','29-MAR-21', 'ZMUZZLEM','29-MAR-21')
/
----------------------------------------- rebuild course
ALTER TABLE COURSE
ADD (SCHOOL_ID NUMBER);

UPDATE COURSE
SET SCHOOL_ID = 1;

ALTER TABLE COURSE
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE COURSE 
ADD (PREREQUISITE_SCHOOL_ID NUMBER);

----------------------------------- rebuild course keys
ALTER TABLE COURSE
ADD CONSTRAINT COURSE_PK PRIMARY KEY 
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE COURSE
ADD CONSTRAINT COURSE_FK1 FOREIGN KEY
(
  PREREQUISITE 
, PREREQUISITE_SCHOOL_ID 
)
REFERENCES COURSE
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE COURSE
ADD CONSTRAINT COURSE_FK2 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;
/

----------------------------------------------rebuild section 
ALTER TABLE SECTION
ADD (SCHOOL_ID NUMBER);

UPDATE SECTION
SET SCHOOL_ID = 1;

ALTER TABLE SECTION
MODIFY (SCHOOL_ID NOT NULL);

------------------------------------------------------ rebuid section keys
ALTER TABLE SECTION
ADD CONSTRAINT SECTION_PK PRIMARY KEY 
(
  SECTION_ID 
, SCHOOL_ID 
)
ENABLE;
/
ALTER TABLE SECTION
ADD CONSTRAINT SECTION_FK1 FOREIGN KEY
(
  COURSE_NO 
, SCHOOL_ID 
)
REFERENCES COURSE
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;
/
ALTER TABLE SECTION
ADD CONSTRAINT SECTION_FK2 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;
/

----------------------------------------------------- rebuild student
ALTER TABLE STUDENT 
ADD (SCHOOL_ID NUMBER );
/
UPDATE STUDENT
SET SCHOOL_ID = 1;
/
ALTER TABLE STUDENT  
MODIFY (SCHOOL_ID NOT NULL);
/
---------------------------------------------- rebuild student keys 
ALTER TABLE STUDENT
ADD CONSTRAINT STUDENT_PK PRIMARY KEY 
(
  STUDENT_ID 
, SCHOOL_ID 
)
ENABLE;
/
--------------- trying to fix
ALTER TABLE STUDENT
ADD CONSTRAINT STUDENT_FK1 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;
/


-------------------------------------------------- rebuild enrollment
ALTER TABLE ENROLLMENT
ADD (SCHOOL_ID NUMBER);

UPDATE ENROLLMENT
SET SCHOOL_ID = 1;

ALTER TABLE ENROLLMENT
MODIFY (SCHOOL_ID NOT NULL);

---------------------------------------------------- rebuild enrollment keys
ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_PK PRIMARY KEY 
(
  STUDENT_ID 
, SECTION_ID 
, SCHOOL_ID 
)
ENABLE;
/
ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK1 FOREIGN KEY
(
  SECTION_ID 
, SCHOOL_ID 
)
REFERENCES SECTION
(
  SECTION_ID 
, SCHOOL_ID 
)
ENABLE;
/
ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK2 FOREIGN KEY
(
  STUDENT_ID 
, SCHOOL_ID 
)
REFERENCES STUDENT
(
  STUDENT_ID 
, SCHOOL_ID 
)
ENABLE;
/
ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK3 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;
/

-----------------------------------------------------
-- TRIGGERS 
----------------------------------------------------- school trigger
CREATE OR REPLACE TRIGGER SCHOOL_FP_TRG BEFORE
    INSERT OR UPDATE on school
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
----------------------------------------------- course trigger
CREATE OR REPLACE TRIGGER COURSE_FP_TRG BEFORE
    INSERT OR UPDATE on course
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
----------------------------------------------- section trigger
CREATE OR REPLACE TRIGGER SECTION_FP_TRG BEFORE
    INSERT OR UPDATE on section
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
------------------------------------------------------------ enrollment trigger
CREATE OR REPLACE TRIGGER ENROLLMENT_FP_TRG BEFORE
    INSERT OR UPDATE on enrollment
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
--------------------------------------------------------- student fp trigger
CREATE OR REPLACE TRIGGER STUDENT_FP_TRG BEFORE
    INSERT OR UPDATE on student
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;
    
    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/

---------------------------------------------------------------- school seq -- Needs to be before trigger
DECLARE
    v_start_value  NUMBER(9);
    v_sql          VARCHAR(2000);
BEGIN
    SELECT
        nvl(MAX(school_id), 0) + 1
    INTO v_start_value
    FROM
        course;

   /* v_sql := 'DROP SEQUENCE COURSE_SEQ ';
    EXECUTE IMMEDIATE v_sql;*/ v_sql := 'CREATE SEQUENCE SCHOOL_SEQ START WITH ' || v_start_value;
    EXECUTE IMMEDIATE v_sql;
END;
/
----------------------------------------------------------------------------------- school trigger
CREATE OR REPLACE TRIGGER SCHOOL_TRG BEFORE
    INSERT OR UPDATE ON school
    FOR EACH ROW
BEGIN
    << column_sequences >> BEGIN
        IF inserting THEN
            SELECT
                school_seq.NEXTVAL
            INTO :new.school_id
            FROM
                sys.dual;

        END IF;

        IF updating THEN
            :new.school_id := :old.school_id;
        END IF;
    END column_sequences;
END;
/