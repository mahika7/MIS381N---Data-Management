

------------
-- Q1 (a)
------------

SET SERVEROUTPUT ON;

-- Begin an anonymous PL/SQL block
DECLARE
  count_reservations NUMBER(5);
BEGIN
  SELECT COUNT(RESERVATION_ID)
  INTO count_reservations
  FROM RESERVATION
  WHERE CUSTOMER_ID = 100002;

  IF count_reservations > 15 THEN
-- DBMS_OUTPUT.PUT_LINE is a function that prints a nice line
    DBMS_OUTPUT.PUT_LINE('The customer has placed more than 15 reservations.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The customer has placed 15 or fewer reservations.' );
  END IF;

END;
/

------------
-- Q1 (b)
------------

DELETE FROM RESERVATION_DETAILS 
WHERE reservation_id = 318;

DELETE FROM RESERVATION 
WHERE reservation_id = 318;

------------
-- Q1 (c)
------------

SET SERVEROUTPUT ON;

-- Begin an anonymous PL/SQL block
DECLARE
  count_reservations NUMBER(5);
BEGIN
  SELECT COUNT(RESERVATION_ID)
  INTO count_reservations
  FROM RESERVATION
  WHERE CUSTOMER_ID = 100002;

  IF count_reservations > 15 THEN
-- DBMS_OUTPUT.PUT_LINE is a function that prints a nice line
    DBMS_OUTPUT.PUT_LINE('The customer has placed more than 15 reservations.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The customer has placed 15 or fewer reservations.' );
  END IF;

END;
/

------------
-- Q1 (d)
------------
ROLLBACK;



------------
-- Q2
------------

SET SERVEROUTPUT ON;

SET DEFINE ON;

--4 Use a substitution variable
DECLARE
    USER_CUSTOMER_ID  NUMBER := &user_defined_id;
    count_reservations NUMBER(5);


BEGIN
  SELECT COUNT(RESERVATION_ID)
  INTO count_reservations
  FROM RESERVATION
  WHERE CUSTOMER_ID = USER_CUSTOMER_ID;

  IF count_reservations > 15 THEN
-- DBMS_OUTPUT.PUT_LINE is a function that prints a nice line
    DBMS_OUTPUT.PUT_LINE('The customer with customer ID: ' || USER_CUSTOMER_ID || ', has placed more than 15 reservations.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The customer with customer ID: ' || USER_CUSTOMER_ID || ', has placed 15 or fewer reservations.' );
  END IF;

END;
/


------------
-- Q3
------------

SET SERVEROUTPUT ON;

BEGIN  
  INSERT INTO CUSTOMER(customer_id, first_name, last_name, email, phone, address_line_1, city, state, zip) 
  VALUES (CUSTOMER_ID_SEQ.nextval, 'John', 'Green', 'johngreen@gmail.com', '7879568978', '2102 West Apt 156', 'Austin', 'TX', 78702 );
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('1 row was inserted into the customer table.');
EXCEPTION

  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Row was not inserted. Unexpected exception occurred.');
 
END;

/

------------
-- Q4
------------
-- a varray with BULK COLLECT and COUNT
DECLARE
  TYPE names_table      IS TABLE OF VARCHAR2(40);
  feature_names          names_table;
BEGIN
  SELECT feature_name    
  BULK COLLECT INTO feature_names
  FROM FEATURES
  WHERE feature_name like 'P%'
  ORDER BY feature_name;

  FOR i IN 1..feature_names.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('Hotel feature ' || i || ': ' || feature_names(i));
  END LOOP;
END;
/

------------
-- Q5
------------

SET SERVEROUTPUT ON;

DECLARE
  CURSOR location_cursor IS
    SELECT l.location_name, l.city, f.feature_name  
    FROM location l
    JOIN location_features_linking lf
    ON l.location_id = lf.location_id
    JOIN FEATURES f
    ON lf.feature_id = f.feature_id
    ORDER BY l.location_name, l.city, f.feature_name ;

  location_row location%ROWTYPE;
BEGIN  
  FOR location_row IN location_cursor LOOP   
  

      DBMS_OUTPUT.PUT_LINE(location_row.location_name || ' in ' || location_row.city || ' has feature: ' || location_row.feature_name);


  END LOOP;
  
END;
/

------------
-- Q5 (Bonus Question)
------------


SET SERVEROUTPUT ON;

DECLARE
  USER_CITY  VARCHAR2(40) := '&user_defined_city';
  
  CURSOR location_cursor IS
    SELECT l.location_name, l.city, f.feature_name  
    FROM location l
    JOIN location_features_linking lf
    ON l.location_id = lf.location_id
    JOIN FEATURES f
    ON lf.feature_id = f.feature_id
    ORDER BY l.location_name, l.city, f.feature_name ;

  location_row location%ROWTYPE;
BEGIN 
  
  FOR location_row IN location_cursor LOOP   
     IF location_row.city = USER_CITY THEN
      DBMS_OUTPUT.PUT_LINE(location_row.location_name || ' in ' || location_row.city || ' has feature: ' || location_row.feature_name);
     END IF;

  END LOOP;
  
END;
/


------------
-- Q6
------------

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE insert_customer( 
                            first_name in CUSTOMER.first_name%type, 
                            last_name in CUSTOMER.last_name%type, 
                            email in CUSTOMER.email%type, 
                            phone in CUSTOMER.phone%type, 
                            address_line_1 in CUSTOMER.address_line_1%type, 
                            city in CUSTOMER.city%type, 
                            state in CUSTOMER.state%type, 
                            zip in CUSTOMER.zip%type)
                            
IS

BEGIN  
  INSERT INTO CUSTOMER 
  VALUES (CUSTOMER_ID_SEQ.nextval, first_name, last_name, email, phone, address_line_1, NULL, city, state, zip, NULL, NULL, NULL);

  DBMS_OUTPUT.PUT_LINE('1 row was inserted into the customer table.');
EXCEPTION

  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Row was not inserted. Unexpected exception occurred.');
    ROLLBACK;
END;

/

CALL insert_customer('Joseph', 'Lee', 'jo12@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
BEGIN
Insert_customer ('Mary', 'Lee', 'jo34@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
END;
/  

------------
-- Q7
------------

CREATE OR REPLACE FUNCTION hold_count(user_id in CUSTOMER.customer_id%type)
RETURN NUMBER

IS

room_count  NUMBER;

BEGIN 

   SELECT COUNT(RESERVATION_ID)
   INTO room_count
   FROM RESERVATION
   WHERE customer_id = user_id;

RETURN room_count;
END;

/
 

select customer_id, hold_count(customer_id)  
from reservation
group by customer_id
order by customer_id;