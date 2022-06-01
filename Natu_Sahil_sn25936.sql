------------
-- Q1
------------
SELECT Cardholder_First_Name, Cardholder_Last_Name, Card_Type, Expiration_Date
FROM Customer_Payment 
ORDER BY Expiration_Date ASC;

------------
-- Q2
------------
SELECT (First_Name || ' ' || Last_Name) AS Customer_Full_Name
FROM Customer 
WHERE SUBSTR(First_Name,1,1) IN('A','B','C') 
ORDER BY Last_Name DESC;

------------
-- Q3
------------
SELECT Customer_ID, Confirmation_Nbr, Date_Created, Check_In_Date, Number_Of_Guests
FROM Reservation
WHERE Status='U' AND Check_In_Date <= TO_DATE('2021/12/31', 'yyyy/mm/dd') AND Check_In_Date >= SYSDATE;

------------
-- Q4
------------
-- Part A
SELECT Customer_ID, Confirmation_Nbr, Date_Created, Check_In_Date, Number_Of_Guests
FROM Reservation
WHERE Status='U' AND (Check_In_Date BETWEEN SYSDATE AND TO_DATE('2021/12/31', 'yyyy/mm/dd'));
-- Part B
SELECT Customer_ID, Confirmation_Nbr, Date_Created, Check_In_Date, Number_Of_Guests
FROM Reservation
WHERE Status='U' AND Check_In_Date <= TO_DATE('2021/12/31', 'yyyy/mm/dd') AND Check_In_Date >= SYSDATE
MINUS
SELECT Customer_ID, Confirmation_Nbr, Date_Created, Check_In_Date, Number_Of_Guests
FROM Reservation
WHERE Status='U' AND (Check_In_Date BETWEEN SYSDATE AND TO_DATE('2021/12/31', 'yyyy/mm/dd'));

------------
-- Q5
------------
SELECT Customer_ID, Location_ID, (Check_Out_Date - Check_In_Date) AS Length_Of_Stay
FROM Reservation
WHERE Status='C' AND ROWNUM<=10
ORDER BY Length_Of_Stay DESC, Customer_ID ASC;

------------
-- Q6
------------
SELECT First_Name, Last_Name, Email, (Stay_Credits_Earned - Stay_Credits_Used) AS Credits_Available
FROM Customer
WHERE (Stay_Credits_Earned - Stay_Credits_Used) >= 10
ORDER BY Credits_Available;

------------
-- Q7
------------
SELECT Cardholder_First_Name, Cardholder_Mid_Name, Cardholder_Last_Name
FROM Customer_Payment
WHERE Cardholder_Mid_Name IS NOT NULL
ORDER BY 2, 3;

------------
-- Q8
------------
SELECT SYSDATE AS Today_Unformatted, TO_CHAR(SYSDATE, 'mm/dd/yyyy') AS Today_Formatted, 25 AS Credits_Earned, (25/10) AS Stays_Earned, FLOOR(25/10) AS Redeemable_Stays, ROUND(25/10) AS Next_Stay_To_Earn
FROM Dual;

------------
-- Q9
------------
SELECT Customer_ID, Location_ID, (Check_Out_Date - Check_In_Date) AS Length_Of_Stay
FROM Reservation
WHERE Status='C' AND Location_ID=2
ORDER BY Length_Of_Stay DESC, Customer_ID ASC
FETCH NEXT 20 ROWS ONLY;

------------
-- Q10
------------
SELECT First_Name, Last_Name, Confirmation_Nbr, Date_Created, Check_In_Date, Check_Out_Date
FROM Reservation
LEFT JOIN Customer
ON Reservation.Customer_ID = Customer.Customer_ID 
WHERE Reservation.Status='C'
ORDER BY Reservation.Customer_ID ASC, Reservation.Check_Out_Date DESC;

------------
-- Q11
------------
SELECT (Customer.First_Name || ' ' || Customer.Last_Name) AS Name, Reservation.Location_ID, Reservation.Confirmation_Nbr, Reservation.Check_In_Date, Room.Room_Number
FROM Reservation
INNER JOIN Customer ON Reservation.Customer_ID = Customer.Customer_ID
INNER JOIN Reservation_Details ON Reservation.Reservation_ID = Reservation_Details.Reservation_ID
INNER JOIN Room ON Reservation_Details.Room_ID = Room.Room_ID
WHERE Reservation.Status='U' AND Customer.Stay_Credits_Earned>40;

------------
-- Q12
------------
SELECT Customer.First_Name, Customer.Last_Name, Reservation.Confirmation_Nbr, Reservation.Date_Created, Reservation.Check_In_Date, Reservation.Check_Out_Date
FROM Customer
LEFT JOIN Reservation ON Customer.Customer_ID = Reservation.Customer_ID
WHERE Reservation.Reservation_ID IS NULL;

------------
-- Q13
------------
SELECT '1-Gold Member' AS Status_Level, First_Name, Last_Name, Email, Stay_Credits_Earned FROM Customer WHERE Stay_Credits_Earned < 10
UNION
SELECT '2-Platinum Member' AS Status_Level, First_Name, Last_Name, Email, Stay_Credits_Earned FROM Customer WHERE Stay_Credits_Earned >= 10 AND Stay_Credits_Earned < 40
UNION
SELECT '3-Diamond Club' AS Status_Level, First_Name, Last_Name, Email, Stay_Credits_Earned FROM Customer WHERE Stay_Credits_Earned >= 40
ORDER BY 1,3;