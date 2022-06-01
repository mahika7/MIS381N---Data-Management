-- Drop all tables ---

BEGIN

FOR c IN (SELECT table_name FROM user_tables) LOOP
EXECUTE IMMEDIATE ('DROP TABLE "' || c.table_name || '" CASCADE CONSTRAINTS');
END LOOP;

FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
EXECUTE IMMEDIATE ('DROP SEQUENCE ' || s.sequence_name);
END LOOP;

END;
/

CREATE SEQUENCE user_id_seq
START WITH 100001;

CREATE SEQUENCE role_id_seq
START WITH 1001;

CREATE SEQUENCE feature_id_seq
START WITH 101;

CREATE SEQUENCE session_id_seq
START WITH 10001;

CREATE SEQUENCE product_id_seq
START WITH 10001;

CREATE SEQUENCE order_id_seq;

CREATE SEQUENCE shipment_id_seq;

CREATE SEQUENCE lineitem_id_seq;

CREATE SEQUENCE invoice_id_seq;




-- Create new tables -- 

CREATE TABLE roles
(
    role_id NUMBER DEFAULT role_id_seq.nextval,
    role_name VARCHAR2(50) NOT NULL,
    CONSTRAINT role_id_pk PRIMARY KEY (role_id)
);

CREATE TABLE features
(
    feature_id       NUMBER          DEFAULT feature_id_seq.nextval,
    feature_name     VARCHAR2(50)    NOT NULL,
    CONSTRAINT features_id_pk PRIMARY KEY (feature_id)
);

CREATE TABLE rolefeaturemapping
(
    feature_id      NUMBER          NOT NULL,
    role_id         NUMBER          NOT NULL,
    CONSTRAINT map_pk PRIMARY KEY (feature_id, role_id),
    CONSTRAINT map_features_fk FOREIGN KEY (feature_id) REFERENCES features(feature_id),
    CONSTRAINT map_roles_fk FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE users
(
    user_id       NUMBER          DEFAULT user_id_seq.nextval,
    role_id       NUMBER          NOT NULL,
    first_name    VARCHAR2(50)    NOT NULL,     
    last_name     VARCHAR2(50)    NOT NULL,  
    email         VARCHAR2(50)    NOT NULL,  
    phone_num     VARCHAR2(12)    NOT NULL,  
    phone_country VARCHAR2(3)     NOT NULL,  
    address_1     VARCHAR2(50)    NOT NULL,
    address_2     VARCHAR2(50),
    city          VARCHAR2(20)    NOT NULL,
    state         VARCHAR2(20),
    country       VARCHAR2(20)    NOT NULL,
    zip_code      VARCHAR2(10)    NOT NULL,
    is_active     NUMBER(1)       Not NULL,
    CONSTRAINT user_id_pk PRIMARY KEY (user_id),
    CONSTRAINT role_id_fk FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE ShipmentAddresses 
(
    address_id  NUMBER  NOT NULL,
    user_id     NUMBER  NOT NULL,
    address_name    varchar2(20)    NOT NULL,
    type        varchar2(20)        NOT NULL,
    address_1   VARCHAR2(50)    NOT NULL,
    address_2   VARCHAR2(50),
    city        VARCHAR2(20)    NOT NULL,
    STATE       VARCHAR2(20),
    COUNTRY     VARCHAR2(20)    NOT NULL,
    zip_code    VARCHAR2(10)    NOT NULL,
    
    CONSTRAINT address_website_pk PRIMARY KEY (address_id, user_id),
    CONSTRAINT user_id_fk1 FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

CREATE TABLE Sessions 
(
    session_id  NUMBER  DEFAULT session_id_seq.nextval,
    user_id     NUMBER  NOT NULL,
    ip_address  VARCHAR2(45) NOT NULL,
    start_time  TIMESTAMP   NOT NULL,
    end_time    TIMESTAMP,

    CONSTRAINT session_id_pk PRIMARY KEY (session_id),
    CONSTRAINT user_id_fk FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

CREATE TABLE Authentication
(
    user_id NUMBER  NOT NULL,
    username VARCHAR2(20)  NOT NULL,
    pwd VARCHAR2(32)  NOT NULL,
    CONSTRAINT auth_user_id_pk PRIMARY KEY (user_id),
    CONSTRAINT auth_user_id_fk FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE Products
(
    product_id NUMBER DEFAULT product_id_seq.nextval,
    product_name VARCHAR2(50) NOT NULL,
    description VARCHAR2(50) NOT NULL,
    type_1 VARCHAR2(50) NOT NULL,
    type_2 VARCHAR2(50) NOT NULL,
    type_3 VARCHAR2(50) NOT NULL,
    CONSTRAINT products_id_pk PRIMARY KEY (product_id)
);

CREATE TABLE Inventory
(
    product_id NUMBER NOT NULL,
    seller_id NUMBER NOT NULL,
    qty NUMBER NOT NULL,
    price NUMBER NOT NULL,
    CONSTRAINT inventory_pk PRIMARY KEY (product_id, seller_id),
    CONSTRAINT inventory_product_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT inventory_seller_fk FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE ShoppingCart
(
    product_id NUMBER NOT NULL,
    buyer_id NUMBER NOT NULL,
    seller_id NUMBER NOT NULL,
    qty NUMBER NOT NULL,
    CONSTRAINT shopping_cart_pk PRIMARY KEY (product_id, buyer_id, seller_id),
    CONSTRAINT shopping_cart_product_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT shopping_cart_buyer_fk FOREIGN KEY (buyer_id) REFERENCES users(user_id),
    CONSTRAINT shopping_cart_seller_fk FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE Orders
(
    order_id NUMBER DEFAULT order_id_seq.nextval,
    buyer_id NUMBER NOT NULL,
    order_date TIMESTAMP NOT NULL,
    order_status varchar2(20) NOT NULL,
    CONSTRAINT order_id_pk PRIMARY KEY (order_id),
    CONSTRAINT orders_buyer_fk FOREIGN KEY (buyer_id) REFERENCES users(user_id)
);



CREATE TABLE Shipments
(
    shipment_id NUMBER DEFAULT shipment_id_seq.nextval,
    address_id NUMBER NOT NULL,
    user_id NUMBER NOT NULL,
    tracking_id varchar2(20),
    shipping_partner varchar2(50),
    expected_date TIMESTAMP,
    actual_date TIMESTAMP,
    CONSTRAINT shipment_id_pk PRIMARY KEY (shipment_id),
    CONSTRAINT shipment_address_fk FOREIGN KEY (address_id, user_id) REFERENCES ShipmentAddresses(address_id, user_id)
);

CREATE TABLE LineItems
(
    lineitem_id NUMBER DEFAULT lineitem_id_seq.nextval,
    order_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    seller_id NUMBER NOT NULL,
    shipment_id NUMBER NOT NULL,
    qty NUMBER NOT NULL,
    price NUMBER NOT NULL,

    CONSTRAINT lineitem_id_pk PRIMARY KEY (lineitem_id, order_id),
    CONSTRAINT lineiten_order_id_fk FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT lineiten_product_id_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT lineiten_seller_id_fk FOREIGN KEY (seller_id) REFERENCES users(user_id),
    CONSTRAINT lineiten_shipment_id_fk FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
    
);

CREATE TABLE Invoices
(
    invoice_id NUMBER DEFAULT invoice_id_seq.nextval,
    order_id NUMBER NOT NULL,
    stripe_invoice_id varchar2(20) NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    CONSTRAINT invoices_id_pk PRIMARY KEY (invoice_id),
    CONSTRAINT invoices_order_fk FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE Reviews
(
    product_id NUMBER NOT NULL,
    buyer_id NUMBER NOT NULL,
    rating NUMBER NOT NULL,
    review varchar2(200),
    review_date TIMESTAMP NOT NULL,
    CONSTRAINT reviews_id_pk PRIMARY KEY (product_id, buyer_id),
    CONSTRAINT reviews_product_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT reviews_buyer_fk FOREIGN KEY (buyer_id) REFERENCES users(user_id)
);

CREATE TABLE PaymentMethods
(
    stripe_card_id varchar2(20) NOT NULL,
    user_id NUMBER NOT NULL,
    stripe_id NUMBER NOT NULL,
    CONSTRAINT pm_id_pk PRIMARY KEY (stripe_card_id),
    CONSTRAINT pm_user_fk FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Insert Data section - Area of the script that inserts data into the tables using �INSERT INTO�

INSERT INTO roles(role_name) VALUES ('Super Admin');
INSERT INTO roles(role_name) VALUES ('Admin');
INSERT INTO roles(role_name) VALUES ('Seller');
INSERT INTO roles(role_name) VALUES ('Buyer');


INSERT INTO FEATURES(feature_name) VALUES ('Selling Portal');
INSERT INTO FEATURES(feature_name) VALUES ('Buying Portal');
INSERT INTO FEATURES(feature_name) VALUES ('Passwords');
INSERT INTO FEATURES(feature_name) VALUES ('xyz');


INSERT INTO rolefeaturemapping(feature_id, role_id) VALUES (101, 1001);
INSERT INTO rolefeaturemapping(feature_id, role_id) VALUES (102, 1001);

Insert into Users (ROLE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUM,PHONE_COUNTRY,ADDRESS_1,ADDRESS_2,CITY,STATE,COUNTRY,ZIP_CODE,IS_ACTIVE) values (1001,'Jamill','Kemm','JKemm@gmail.com','555-263-4329','1', '9 Burrows Avenue','Apt 1B','San Antonio','TX','US','75897',1);
Insert into Users (ROLE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUM,PHONE_COUNTRY,ADDRESS_1,ADDRESS_2,CITY,STATE,COUNTRY,ZIP_CODE,IS_ACTIVE) values (1002,'Jefferey','Kosiada','JKosiada@yahoo.com','555-263-5955','91', '3 Iowa Street',null,'Shreveport','LA','INDIA','79024',0);
Insert into Users (ROLE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUM,PHONE_COUNTRY,ADDRESS_1,ADDRESS_2,CITY,STATE,COUNTRY,ZIP_CODE,IS_ACTIVE) values (1003,'Joline','Gloyens','JG966@gmail.com','555-263-5955','92', '6795 Graedel Street','B2','Syracuse','NY','PAKISTAN','10005',1);
Insert into Users (ROLE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUM,PHONE_COUNTRY,ADDRESS_1,ADDRESS_2,CITY,STATE,COUNTRY,ZIP_CODE,IS_ACTIVE) values (1004,'Kary','Klimkowski','hookemfan192@hyper.net','144-402-5732','1', '14 Bluejay Crossing',null,'Spring','TX','US','78267',0);



Insert into ShipmentAddresses (address_id, user_id, address_name,type, address_1, address_2, city, STATE, COUNTRY, zip_code) values (1025 ,100001 , 'Amazon', 'Business','9 Burrows Avenue',null,'San Antonio','TX', 'US','75897');
Insert into ShipmentAddresses (address_id, user_id, address_name,type, address_1, address_2, city, STATE, COUNTRY, zip_code) values (1028 ,100002 , 'Tesla', 'Business','11 Avenue',null,'Austin','TX', 'US','75823');


Insert into Sessions (user_id, ip_address, start_time, end_time) values (100001, '206.71.50.230', TO_DATE ('3/13/2021 9:22:00 AM', 'MM/DD/YYYY HH:MI:SS AM'), TO_DATE ('3/13/2021 9:29:00 AM', 'MM/DD/YYYY HH:MI:SS AM'));
Insert into Sessions (user_id, ip_address, start_time, end_time) values (100002, '291.71.50.230', TO_DATE ('3/15/2021 10:52:00 AM', 'MM/DD/YYYY HH:MI:SS AM'), TO_DATE ('3/18/2021 9:55:00 AM', 'MM/DD/YYYY HH:MI:SS AM'));

    
    
Insert into Authentication (user_id, username, pwd) values (100001, 'joline_gloyens', 'gloyens_7' );
Insert into Authentication (user_id, username, pwd) values (100002, 'jol_glo', 'glo' );




Insert into Products (product_name, description, type_1, type_2, type_3) values ('Pens','Ballpoint Pens','Black', 'Sharp', 'Cylinder');
Insert into Products (product_name, description, type_1, type_2, type_3) values ('Desktops','HP Desktops','Black', 'xyz', 'abc');



Insert into Inventory (product_id, seller_id, qty, price) values (10001, 100001, 10, 20);
Insert into Inventory (product_id, seller_id, qty, price) values (10002, 100002, 20, 30);


Insert into ShoppingCart (product_id, buyer_id, seller_id, qty) values (10001, 100002, 100001, 5);
Insert into ShoppingCart (product_id, buyer_id, seller_id, qty) values (10002, 100003, 100001, 15);


 
Insert into Orders (buyer_id, order_date, order_status) values (100001, TO_DATE('03/13/2021', 'MM/DD/YYYY'), 'Completed');
Insert into Orders (buyer_id, order_date, order_status) values (100002, TO_DATE('11/21/2021', 'MM/DD/YYYY'), 'Not Completed');
  
 
Insert into Shipments (address_id, user_id, tracking_id, shipping_partner, expected_date, actual_date) values (1025, 100001, 'ABCDEFG', 'DHL',TO_DATE('03/17/2021', 'MM/DD/YYYY'), TO_DATE('03/19/2021', 'MM/DD/YYYY'));
Insert into Shipments (address_id, user_id, tracking_id, shipping_partner, expected_date, actual_date) values (1028, 100002, 'CDEFGAA', 'DHL',TO_DATE('11/22/2021', 'MM/DD/YYYY'), TO_DATE('11/25/2021', 'MM/DD/YYYY'));

 
Insert into LineItems (order_id, product_id, seller_id, shipment_id, qty, price) values (1, 10001 , 100001, 1, 10, 25);
Insert into LineItems (order_id, product_id, seller_id, shipment_id, qty, price) values (2, 10002 , 100002, 2, 20, 28);
   
 
Insert into Invoices (order_id, stripe_invoice_id, invoice_date) values (1, 1023, TO_DATE('03/17/2021', 'MM/DD/YYYY'));
Insert into Invoices (order_id, stripe_invoice_id, invoice_date) values (2, 1025, TO_DATE('11/25/2021', 'MM/DD/YYYY'));
  

Insert into Reviews (product_id, buyer_id,  rating, review, review_date) values (10001, 100001, 5, 'Product is great',TO_DATE('03/17/2021', 'MM/DD/YYYY'));
Insert into Reviews (product_id, buyer_id,  rating, review, review_date) values (10002, 100002, 1, 'Product is bad',TO_DATE('11/25/2021', 'MM/DD/YYYY'));

 
Insert into PaymentMethods (stripe_card_id, user_id, stripe_id) values ('DDGYTJK13232',100001, 554533);
Insert into PaymentMethods (stripe_card_id, user_id, stripe_id) values ('ABFYTJK13777',100002, 554678);
 
 