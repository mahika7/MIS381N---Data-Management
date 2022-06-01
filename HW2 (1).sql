-- Drop Tables and Sequences and Indices
DROP INDEX customer_state_ix;
DROP INDEX customer_payment_customer_id_ix;
DROP INDEX reservation_customer_id_ix;
DROP INDEX reservation_status_ix;
DROP INDEX room_location_id_ix;
DROP TABLE Reservation_Details;
DROP TABLE Location_Features_Linking;
DROP TABLE Features;
DROP TABLE Room;
DROP TABLE "Location";
DROP TABLE Reservation;
DROP TABLE Customer_Payment;
DROP TABLE Customer;
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE room_id_seq;
DROP SEQUENCE location_id_seq;
DROP SEQUENCE feature_id_seq;
DROP SEQUENCE customer_id_seq;

-- Create Tables and Sequences
CREATE SEQUENCE payment_id_seq
  START WITH 1;
CREATE SEQUENCE reservation_id_seq
  START WITH 1;
CREATE SEQUENCE room_id_seq
  START WITH 1;
CREATE SEQUENCE location_id_seq
  START WITH 1;
CREATE SEQUENCE feature_id_seq
  START WITH 1;
CREATE SEQUENCE customer_id_seq
  START WITH 100001; 
CREATE TABLE Customer
(
    Customer_ID         NUMBER       DEFAULT customer_id_seq.nextval,
    First_Name          VARCHAR2(50) NOT NULL,
    Last_Name           VARCHAR2(50) NOT NULL,
    Email               VARCHAR2(50) NOT NULL,
    Phone               CHAR(12)     NOT NULL,
    Address_Line_1      VARCHAR2(50) NOT NULL,
    Address_Line_2      VARCHAR2(50),
    City                VARCHAR2(50) NOT NULL,
    "State"             CHAR(2)      NOT NULL,
    Zip                 CHAR(5)      NOT NULL,
    Birthdate           DATE,
    Stay_Credits_Earned NUMBER       DEFAULT 0 NOT NULL,
    Stay_Credits_Used   NUMBER       DEFAULT 0 NOT NULL,
    CONSTRAINT customer_pk
        PRIMARY KEY (Customer_ID),
    CONSTRAINT customer_email_uq
        UNIQUE (Email),
    CONSTRAINT email_length_check
        CHECK (length(Email)>=7),
    CONSTRAINT credits_check
        CHECK (Stay_Credits_Used <= Stay_Credits_Earned)
);
CREATE TABLE Customer_Payment
(
    Payment_ID              NUMBER          DEFAULT payment_id_seq.nextval,
    Customer_ID             NUMBER          NOT NULL,
    Cardholder_First_Name   VARCHAR2(50)    NOT NULL,
    Cardholder_Mid_Name     VARCHAR2(50), --mention nullable assumption in report
    Cardholder_Last_Name    VARCHAR2(50)    NOT NULL,
    Card_Type               CHAR(4)         NOT NULL,
    Card_Number             VARCHAR2(16)    NOT NULL,
    Expiration_Date         DATE            NOT NULL,
    CC_ID                   VARCHAR2(3)     NOT NULL,
    Billing_Address         VARCHAR(50)     NOT NULL,
    Billing_City            VARCHAR(50)     NOT NULL,
    Billing_State           CHAR(2)         NOT NULL, --mention char(2) assumption in report
    Billing_Zip             CHAR(5)         NOT NULL, --mention char(5) assumption in report
    CONSTRAINT customer_payment_pk
        PRIMARY KEY (Payment_ID),
    CONSTRAINT payment_fk_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID)
    --CONSTRAINT customer_uq
    --    UNIQUE (Customer_ID)
);
CREATE TABLE Reservation
(
    Reservation_ID          NUMBER          DEFAULT reservation_id_seq.nextval,
    Customer_ID             NUMBER          NOT NULL,
    Confirmation_Nbr        CHAR(8)         NOT NULL,
    Date_Created            DATE            DEFAULT SYSDATE NOT NULL,
    Check_In_Date           DATE            NOT NULL,
    Check_Out_Date          DATE,
    Status                  CHAR(1)         NOT NULL,
    Discount_Code           VARCHAR2(50),
    Reservation_Total       NUMBER          DEFAULT 0 NOT NULL,
    Customer_Rating         NUMBER,
    Notes                   VARCHAR2(500), --mention varchar2 len in assumptions in report
    CONSTRAINT reservation_pk
        PRIMARY KEY (Reservation_ID),
    CONSTRAINT reservation_fk_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID),
    CONSTRAINT confirmation_nbr_uq
        UNIQUE (Confirmation_Nbr),
    CONSTRAINT status_check
        CHECK (Status in ('U','I','C','N','R'))
);
CREATE TABLE "Location"
(
    Location_ID     NUMBER           DEFAULT location_id_seq.nextval,
    Location_Name   VARCHAR2(50)     NOT NULL,
    Address         VARCHAR2(50)     NOT NULL,
    City            VARCHAR2(50)     NOT NULL,
    "State"         CHAR(2)          NOT NULL, --mention char(2) assumption in report
    Zip             CHAR(5)          NOT NULL, --mention char(5) assumption in report
    Phone           CHAR(12)         NOT NULL, --mention char(12) assumption in report
    "URL"           VARCHAR2(50)     NOT NULL,
    CONSTRAINT location_pk
        PRIMARY KEY (Location_ID),
    CONSTRAINT location_name_uq
        UNIQUE (Location_Name)
);
CREATE TABLE Features
(
    "Feature_ID"      NUMBER        DEFAULT feature_id_seq.nextval,
    Feature_Name      VARCHAR(50),
    CONSTRAINT feature_pk
        PRIMARY KEY ("Feature_ID"),
    CONSTRAINT feature_name_uq
        UNIQUE (Feature_Name)
);
CREATE TABLE Location_Features_Linking
(
    Location_ID     NUMBER,
    "Feature_ID"    NUMBER,
    CONSTRAINT location_feature_linking_pk
        PRIMARY KEY (Location_ID, "Feature_ID"),
    CONSTRAINT location_fk
        FOREIGN KEY (Location_ID)
        REFERENCES "Location" (Location_ID),
    CONSTRAINT features_fk
        FOREIGN KEY ("Feature_ID")
        REFERENCES Features ("Feature_ID")
);
CREATE TABLE Room
(
    Room_ID         NUMBER      DEFAULT room_id_seq.nextval,
    Location_ID     NUMBER,
    Floor           NUMBER      NOT NULL,
    Room_Number     NUMBER      NOT NULL,
    Room_Type       CHAR(1)     NOT NULL,
    Square_Footage  NUMBER      NOT NULL,
    Max_People      NUMBER      NOT NULL,
    Weekday_Rate    NUMBER      NOT NULL,
    Weekend_Rate    NUMBER      NOT NULL,
    CONSTRAINT room_pk
        PRIMARY KEY (Room_ID),
    CONSTRAINT room_fk_location
        FOREIGN KEY (Location_ID)
        REFERENCES "Location" (Location_ID),
    CONSTRAINT room_type_check
        CHECK (Room_Type in ('D','Q','K','S','C'))
);
CREATE TABLE Reservation_Details
(
    Reservation_ID      NUMBER,
    Room_ID             NUMBER,
    Number_of_Guests    NUMBER      NOT NULL,
    CONSTRAINT reservation_details_pk
        PRIMARY KEY (Reservation_ID, Room_ID),
    CONSTRAINT reservation_fk
        FOREIGN KEY (Reservation_ID)
        REFERENCES Reservation (Reservation_ID),
    CONSTRAINT room_fk
        FOREIGN KEY (Room_ID)
        REFERENCES Room (Room_ID)
);

-- Insert Data
INSERT INTO "Location" VALUES
(
    DEFAULT,
    'South Congress',
    '411 South Congress Ave',
    'Austin',
    'TX',
    '78701',
    '512-098-5674',
    'southcongress@sourapplestays.com'
);
INSERT INTO "Location" VALUES
(
    DEFAULT,
    'East 7th Lofts',
    '599 East 7th St',
    'Austin',
    'TX',
    '78702',
    '512-098-5677',
    'east7lofts@sourapplestays.com'
);
INSERT INTO "Location" VALUES
(
    DEFAULT,
    'Balcones Canyonloands',
    '109 Lamar St',
    'Marble Falls',
    'TX',
    '78657',
    '512-090-5670',
    'balconescanyonlands@sourapplestays.com'
);
INSERT INTO Features VALUES
(
    DEFAULT,
    'Swimming Pool'
);
INSERT INTO Features VALUES
(
    DEFAULT,
    'WiFi'
);
INSERT INTO Features VALUES
(
    DEFAULT,
    'Car Rentals'
);
INSERT INTO Location_Features_Linking VALUES
(
    1,
    2
);
INSERT INTO Location_Features_Linking VALUES
(
    1,
    3
);
INSERT INTO Location_Features_Linking VALUES
(
    2,
    1
);
INSERT INTO Location_Features_Linking VALUES
(
    2,
    2
);
INSERT INTO Location_Features_Linking VALUES
(
    2,
    3
);
INSERT INTO Location_Features_Linking VALUES
(
    3,
    2
);
INSERT INTO Location_Features_Linking VALUES
(
    3,
    3
);
INSERT INTO Room VALUES
(
    DEFAULT,
    1,
    3,
    27,
    'Q',
    290,
    2,
    140,
    180
);
INSERT INTO Room VALUES
(
    DEFAULT,
    1,
    9,
    3,
    'S',
    750,
    4,
    550,
    600
);
INSERT INTO Room VALUES
(
    DEFAULT,
    2,
    2,
    32,
    'Q',
    350,
    3,
    160,
    190
);
INSERT INTO Room VALUES
(
    DEFAULT,
    2,
    1,
    21,
    'D',
    220,
    2,
    130,
    150
);
INSERT INTO Room VALUES
(
    DEFAULT,
    3,
    0,
    14,
    'C',
    400,
    6,
    200,
    250
);
INSERT INTO Room VALUES
(
    DEFAULT,
    3,
    0,
    7,
    'C',
    350,
    4,
    160,
    210
);
INSERT INTO Customer VALUES
(
    DEFAULT,
    'Sahil',
    'Natu',
    'sn25936@utexas.edu',
    '669-334-9876',
    '1109 East Ave',
    'Apt 445',
    'Austin',
    'TX',
    '78702',
    TO_DATE('1995/01/01', 'yyyy/mm/dd'),
    0,
    0
);

INSERT INTO Customer_Payment VALUES
(
    DEFAULT,
    100001,
    'Sahil',
    NULL,
    'Natu',
    'VISA',
    '9876998765489007',
    TO_DATE('2023/08/01', 'yyyy/mm/dd'),
    '765',
    '1109 East Ave Apt 445',
    'Austin',
    'TX',
    '78702'
);

INSERT INTO Customer VALUES
(
    DEFAULT,
    'Mohammed',
    'Lee',
    'm.lee.fake@utexas.edu',
    '110-330-5500',
    '007 North Ave',
    NULL,
    'Boston',
    'MA',
    '02200',
    TO_DATE('1980/01/01', 'yyyy/mm/dd'),
    59,
    20
);

INSERT INTO Customer_Payment VALUES
(
    DEFAULT,
    100002,
    'Mohammed',
    'Z',
    'Lee',
    'MSTR',
    '8766099865579445',
    TO_DATE('2026/02/01', 'yyyy/mm/dd'),
    '999',
    '007 North Ave',
    'Boston',
    'MA',
    '02200'
);

INSERT INTO Reservation VALUES
(
    DEFAULT,
    100001,
    'WER876A2',
    SYSDATE,
    TO_DATE('2021/10/21', 'yyyy/mm/dd'),
    NULL,
    'U',
    NULL,
    740,
    NULL,
    'Rental car required by the customer at the time of check-in'
);
INSERT INTO Reservation_Details VALUES
(
    1,
    6,
    4
);
INSERT INTO Reservation VALUES
(
    DEFAULT,
    100002,
    'UIU876Y0',
    SYSDATE,
    TO_DATE('2021/08/11', 'yyyy/mm/dd'),
    TO_DATE('2021/08/12', 'yyyy/mm/dd'),
    'C',
    'WW33456798Y6',
    550,
    4.5,
    NULL
);
INSERT INTO Reservation_Details VALUES
(
    2,
    2,
    3
);
INSERT INTO Reservation VALUES
(
    DEFAULT,
    100002,
    'RET895C2',
    SYSDATE,
    TO_DATE('2021/09/30', 'yyyy/mm/dd'),
    TO_DATE('2021/10/02', 'yyyy/mm/dd'),
    'I',
    NULL,
    260,
    NULL,
    NULL
);
INSERT INTO Reservation_Details VALUES
(
    3,
    4,
    1
);
COMMIT;

-- Create Index

CREATE INDEX customer_state_ix
  ON Customer ("State");   
CREATE INDEX customer_payment_customer_id_ix 
  ON Customer_Payment (Customer_ID); 
CREATE INDEX reservation_customer_id_ix
  ON Reservation (Customer_ID);
CREATE INDEX reservation_status_ix
  ON Reservation(Status);
CREATE INDEX room_location_id_ix
  ON Room(Location_ID);

