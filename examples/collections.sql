set SERVEROUTPUT ON;

DECLARE 
CURSOR name_cur is
SELECT last_name
from student 
where rownum < 10;

TYPE last_name_type IS TABLE OF student.last_name%TYPE -- table of student last name column
INDEX BY PLS_INTEGER;
last_name_tab last_name_type; -- table name. type name

v_index PLS_INTEGER := 0; -- v_index start at 0

BEGIN
FOR name_rec in name_cur
LOOP
v_index := v_index + 1; -- increment each loop
last_name_tab(v_index) := name_rec.last_name;
DBMS_OUTPUT.PUT_LINE('last_name('||v_index||'): '||last_name_tab(v_index));
END LOOP;
END;
/
-- nested table
DECLARE 
cursor name_curr is
select last_name
from student
where rownum < 10;

TYPE last_name_type IS TABLE OF student.last_name%TYPE;
last_name_tab last_name_type := last_name_type();

v_index PLS_INTEGER := 0;

BEGIN

for name_rec in name_curr
loop
v_index := v_index + 1;
last_name_tab.EXTEND;
last_name_tab(v_index) := name_rec.last_name;
DBMS_OUTPUT.PUT_LINE('last_name('||v_index||'): '||last_name_tab(v_index));
END LOOP;
END;
/
-------------------------------------------------------------------------------------------
--USE ALL COLLECTION METHODS
-- associative array
DECLARE 
TYPE index_by_type IS TABLE OF NUMBER
INDEX BY PLS_INTEGER;
index_by_table index_by_type;
-- nested table
TYPE nested_type IS TABLE OF NUMBER;
nested_table nested_type := nested_type(1,2,3,4,5,6,7,8,9,10);

BEGIN 
-- POPULATE ARRAY for index_by_table

FOR i in 1..10
LOOP
index_by_table(i) := i;
END LOOP;

-- check if the associative array has third element
IF index_by_table.EXISTS(3)
THEN 
DBMS_OUTPUT.PUT_LINE('index_by_table(3) = ' || index_by_table(3));
END IF;
-- DELETE KEEPS PLACEHOLDERS
-- delete 10th element from array
index_by_table.DELETE(10);
-- delete from nested table
nested_table.DELETE(10);
-- delete from nested table 1 through 3
nested_table.DELETE(1,3);

-- get element count
DBMS_OUTPUT.PUT_LINE('index_by_table.COUNT = ' || index_by_table.count);
DBMS_OUTPUT.PUT_LINE('nested_table.COUNT = ' || nested_table.count);

-- get first and last indexes of array
DBMS_OUTPUT.PUT_LINE('index_by_table.FIRST = ' || index_by_table.FIRST);
DBMS_OUTPUT.PUT_LINE('index_by_table.LAST = ' || index_by_table.LAST);
DBMS_OUTPUT.PUT_LINE('nested_table.FIRST = ' || nested_table.FIRST);
DBMS_OUTPUT.PUT_LINE('Nested_table.LAST = ' || nested_table.LAST);

-- get indexes that precede and succedd 2nd indexes of the associative array
-- and nested table

DBMS_OUTPUT.PUT_LINE('index_by_table.PRIOR(2) = ' || index_by_table.PRIOR(2));
DBMS_OUTPUT.PUT_LINE('index_by_table.NEXT(2) = ' || index_by_table.NEXT(2));
DBMS_OUTPUT.PUT_LINE('nested_table.PRIOR(2) = ' || index_by_table.PRIOR(2));
DBMS_OUTPUT.PUT_LINE('nested_table.NEXT(2) = ' || nested_table.NEXT(2));

DBMS_OUTPUT.PUT_LINE('Nested_table.LAST = ' || nested_table.LAST);
--delete last two elements of table and removes placeholders
nested_table.TRIM(2);

-- delete last element 
nested_table.TRIM;

DBMS_OUTPUT.PUT_LINE('Nested_table.LAST = ' || nested_table.LAST);
END;
/
-- VARRAYS

DECLARE 
CURSOR name_cur is
select last_name
from student
where rownum < 10;

type last_name_type IS VARRAY(10) OF student.last_name%type;
last_name_varray last_name_type := last_name_type();

v_index PLS_INTEGER := 0;

BEGIN 
FOR name_rec in name_cur
LOOP
v_index := v_index + 1;
last_name_varray.extend;
last_name_varray(v_index) := name_rec.last_name;

DBMS_OUTPUT.PUT_LINE('last_name('||v_index||'):'|| last_name_varray(v_index));
END LOOP;
END;
/

declare
type varray_type is varray(10) of number;
varray varray_type := varray_type(1,2,3,4,5,6);

begin 
DBMS_OUTPUT.PUT_LINE('varray.COUNT = ' || varray.COUNT);
DBMS_OUTPUT.PUT_LINE('varray.LIMIT = ' || varray.LIMIT);

DBMS_OUTPUT.PUT_LINE('varray.FIRST = ' || varray.FIRST);
DBMS_OUTPUT.PUT_LINE('varray.LAST = ' || varray.LAST);

varray.EXTEND(2,4); --append two elements from the 4th slot to the collection

DBMS_OUTPUT.PUT_LINE('varray.LAST = ' || varray.LAST);
DBMS_OUTPUT.PUT_LINE('varray('||varray.LAST||') = '||varray(varray.LAST));

varray.TRIM(2); --removes last two items and does not give them a placeholder.

DBMS_OUTPUT.PUT_LINE('varray.LAST = '||varray.LAST);
END;