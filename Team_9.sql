------------
-- Q1
------------
SELECT COUNT(*) AS count_of_customers, MIN(stay_credits_earned) AS min_credits, MAX(stay_credits_earned) AS max_credits
FROM customer;

------------
-- Q2
------------
SELECT Customer.Customer_Id, COUNT(Reservation_Id) AS Number_Of_Reservations, MIN(Check_In_Date) AS Earliest_Check_In
FROM Customer
INNER JOIN Reservation ON Customer.Customer_Id = Reservation.Customer_Id
GROUP BY Customer.Customer_Id;

------------
-- Q3
------------
SELECT City, State, ROUND(AVG(Stay_Credits_Earned),0) AS Avg_Credits_Earned
FROM Customer
GROUP BY City, State
ORDER BY State, Avg_Credits_Earned DESC;

------------
-- Q4
------------
SELECT Reservation.Customer_Id, Customer.Last_Name, Room.Room_Number, COUNT(Reservation_Details.Reservation_Id) AS Stay_Count, CASE WHEN COUNT(Reservation_Details.Reservation_Id) > 1 THEN 'Yes' ELSE 'No' END AS Multiple_Stays
FROM Reservation
INNER JOIN Customer ON Reservation.Customer_Id = Customer.Customer_Id
INNER JOIN Reservation_Details ON Reservation.Reservation_Id = Reservation_Details.Reservation_Id
INNER JOIN Room ON Reservation_Details.Room_Id = Room.Room_Id
WHERE Reservation.Location_Id = 1
GROUP BY Reservation.Customer_Id, Customer.Last_Name, Room.Room_Number
ORDER BY Reservation.Customer_Id ASC, Stay_Count DESC;

------------
-- Q5
------------
SELECT Reservation.Customer_Id, Customer.Last_Name, Room.Room_Number, COUNT(Reservation_Details.Reservation_Id) AS Stay_Count, CASE WHEN COUNT(Reservation_Details.Reservation_Id) > 1 THEN 'Yes' ELSE 'No' END AS Multiple_Stays
FROM Reservation
INNER JOIN Customer ON Reservation.Customer_Id = Customer.Customer_Id
INNER JOIN Reservation_Details ON Reservation.Reservation_Id = Reservation_Details.Reservation_Id
INNER JOIN Room ON Reservation_Details.Room_Id = Room.Room_Id
WHERE Reservation.Location_Id = 1 AND Reservation.Status = 'C'
GROUP BY Reservation.Customer_Id, Customer.Last_Name, Room.Room_Number
HAVING NOT COUNT(Reservation_Details.Reservation_Id) <= 2;

------------
-- Q6
------------
SELECT Location.Location_Name, Reservation.Check_In_Date, SUM(Reservation.Number_Of_Guests) as Number_Of_Guests
FROM Reservation
INNER JOIN Location ON Reservation.Location_Id = Location.Location_Id
WHERE Reservation.Check_In_Date > SYSDATE
GROUP BY ROLLUP(Location.Location_Name, Reservation.Check_In_Date);

-- CUBE operator provides subtotals across all dimensions passed into the function. It would have provided subtotals across all Check In Dates in addition to the subtotals across all Location Names in the above query. The ROLLUP operator provides subtotals based on the order of dimensions passed into the function. It provides subtotals across Location Names by adding number of guests at each Check In Date within, but does not provide a subtotal across each Check In Date.

------------
-- Q7
------------
SELECT Features.Feature_Name, COUNT(Location_Features_Linking.Location_Id) AS Count_Of_Locations
FROM Features
LEFT JOIN Location_Features_Linking ON Features.Feature_Id = Location_Features_Linking.Feature_Id
GROUP BY Features.Feature_Name
HAVING COUNT(Location_Features_Linking.Location_Id) > 2;

------------
-- Q8
------------
SELECT Customer_Id, First_Name, Last_Name, Email
FROM Customer
WHERE Customer_Id NOT IN
    (SELECT Customer_Id
    FROM Reservation)
;

------------
-- Q9
------------
SELECT First_Name, Last_Name, Email, Phone, Stay_Credits_Earned
FROM Customer
WHERE Stay_Credits_Earned >
    (SELECT AVG(Stay_Credits_Earned)
    FROM Customer)
ORDER BY Stay_Credits_Earned DESC;

------------
-- Q10
------------
SELECT City, State, Total_Earned - Total_Used AS Credits_Remaining
FROM
    (SELECT City, State, SUM(Stay_Credits_Earned) AS Total_Earned, SUM(Stay_Credits_Used) AS Total_Used
    FROM Customer
    GROUP BY City, State)
ORDER BY Credits_Remaining DESC;

------------
-- Q11
------------
SELECT Reservation.Confirmation_Nbr, Reservation.Date_Created, Reservation.Check_In_Date, Reservation.Status, Reservation_Details.Room_Id
FROM Reservation
INNER JOIN Reservation_Details ON Reservation.Reservation_Id = Reservation_Details.Reservation_Id
WHERE Reservation_Details.Room_Id IN
    (SELECT Room_Id
    FROM Reservation_Details
    GROUP BY Room_Id
    HAVING COUNT(Reservation_Id) < 5)
AND Reservation.Status <> 'C';

------------
-- Q12
------------
SELECT Cardholder_First_Name, Cardholder_Last_Name, Card_Number, Expiration_Date, CC_ID
FROM Customer_Payment
WHERE Customer_ID IN
    (SELECT Customer_Id
    FROM Reservation
    WHERE Status = 'C'
    GROUP BY Customer_Id
    HAVING COUNT(Reservation_Id) = 1)
AND Card_Type = 'MSTR';