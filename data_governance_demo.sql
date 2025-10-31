-- ============================================================================
-- SNOWFLAKE DATA GOVERNANCE DEMO - SNOWSIGHT NOTEBOOK
-- ============================================================================
-- Complete end-to-end workflow demonstrating automated discovery, 
-- classification, and secure data access policies
-- ============================================================================

-- ============================================================================
-- SECTION 1: SETUP & INITIALIZATION
-- ============================================================================

-- Step 1.1: Create Roles
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS data_steward;
CREATE ROLE IF NOT EXISTS analyst;
CREATE ROLE IF NOT EXISTS limited_user;
CREATE ROLE IF NOT EXISTS governance_admin;

-- Step 1.2: Create Warehouse
CREATE WAREHOUSE IF NOT EXISTS demo_governance_wh
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

GRANT USAGE ON WAREHOUSE demo_governance_wh TO ROLE data_steward;
GRANT USAGE ON WAREHOUSE demo_governance_wh TO ROLE analyst;
GRANT USAGE ON WAREHOUSE demo_governance_wh TO ROLE limited_user;
GRANT USAGE ON WAREHOUSE demo_governance_wh TO ROLE governance_admin;

-- Step 1.3: Create Databases
CREATE DATABASE IF NOT EXISTS governance_objects;
CREATE DATABASE IF NOT EXISTS manual_classification;
CREATE DATABASE IF NOT EXISTS auto_classification;

GRANT USAGE ON DATABASE governance_objects TO ROLE governance_admin;
GRANT USAGE ON DATABASE governance_objects TO ROLE data_steward;
GRANT USAGE ON DATABASE manual_classification TO ROLE governance_admin;
GRANT USAGE ON DATABASE manual_classification TO ROLE data_steward;
GRANT USAGE ON DATABASE auto_classification TO ROLE governance_admin;
GRANT USAGE ON DATABASE auto_classification TO ROLE data_steward;
GRANT USAGE ON DATABASE auto_classification TO ROLE analyst;
GRANT USAGE ON DATABASE auto_classification TO ROLE limited_user;

-- Step 1.4: Create Schemas
USE DATABASE governance_objects;
CREATE SCHEMA IF NOT EXISTS metrics;
CREATE SCHEMA IF NOT EXISTS policies;

USE DATABASE manual_classification;
CREATE SCHEMA IF NOT EXISTS raw_data;

USE DATABASE auto_classification;
CREATE SCHEMA IF NOT EXISTS raw_data;
CREATE SCHEMA IF NOT EXISTS transformed;

-- Step 1.5: Grant Schema Privileges
GRANT USAGE ON SCHEMA governance_objects.metrics TO ROLE governance_admin;
GRANT USAGE ON SCHEMA governance_objects.metrics TO ROLE data_steward;
GRANT USAGE ON SCHEMA governance_objects.policies TO ROLE governance_admin;
GRANT USAGE ON SCHEMA manual_classification.raw_data TO ROLE governance_admin;
GRANT USAGE ON SCHEMA manual_classification.raw_data TO ROLE data_steward;
GRANT USAGE ON SCHEMA auto_classification.raw_data TO ROLE governance_admin;
GRANT USAGE ON SCHEMA auto_classification.raw_data TO ROLE data_steward;
GRANT USAGE ON SCHEMA auto_classification.raw_data TO ROLE analyst;
GRANT USAGE ON SCHEMA auto_classification.raw_data TO ROLE limited_user;
GRANT USAGE ON SCHEMA auto_classification.transformed TO ROLE governance_admin;
GRANT USAGE ON SCHEMA auto_classification.transformed TO ROLE data_steward;
GRANT USAGE ON SCHEMA auto_classification.transformed TO ROLE analyst;
GRANT USAGE ON SCHEMA auto_classification.transformed TO ROLE limited_user;

-- ============================================================================
-- SECTION 2: MANUAL CLASSIFICATION DATABASE - BASE TABLES WITH SAMPLE DATA (50 ROWS EACH)
-- ============================================================================

USE DATABASE manual_classification;
USE SCHEMA raw_data;

-- Table 2.1: Customer PII Data (Personal Identifiable Information)
CREATE OR REPLACE TABLE customers_pii (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    social_security_number VARCHAR(11),
    address_line1 VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

INSERT INTO customers_pii VALUES
(1, 'John', 'Smith', 'john.smith@email.com', '555-0101', '1985-03-15', '123-45-6789', '123 Main St', 'New York', 'NY', '10001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(2, 'Jane', 'Doe', 'jane.doe@email.com', '555-0102', '1990-07-22', '234-56-7890', '456 Oak Ave', 'Los Angeles', 'CA', '90001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(3, 'Michael', 'Johnson', 'michael.j@email.com', '555-0103', '1978-11-30', '345-67-8901', '789 Pine Rd', 'Chicago', 'IL', '60601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(4, 'Emily', 'Williams', 'emily.w@email.com', '555-0104', '1992-05-18', '456-78-9012', '321 Elm St', 'Houston', 'TX', '77001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(5, 'David', 'Brown', 'david.brown@email.com', '555-0105', '1987-09-25', '567-89-0123', '654 Maple Dr', 'Phoenix', 'AZ', '85001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(6, 'Sarah', 'Davis', 'sarah.davis@email.com', '555-0106', '1995-01-12', '678-90-1234', '987 Cedar Ln', 'Philadelphia', 'PA', '19101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(7, 'Robert', 'Miller', 'robert.m@email.com', '555-0107', '1983-08-05', '789-01-2345', '147 Birch Way', 'San Antonio', 'TX', '78201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(8, 'Lisa', 'Wilson', 'lisa.wilson@email.com', '555-0108', '1989-12-28', '890-12-3456', '258 Spruce Ct', 'San Diego', 'CA', '92101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(9, 'James', 'Moore', 'james.moore@email.com', '555-0109', '1991-04-14', '901-23-4567', '369 Willow Pl', 'Dallas', 'TX', '75201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(10, 'Mary', 'Taylor', 'mary.taylor@email.com', '555-0110', '1986-10-07', '012-34-5678', '741 Cherry Blvd', 'San Jose', 'CA', '95101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(11, 'William', 'Anderson', 'william.a@email.com', '555-0111', '1993-06-20', '123-45-6790', '852 Ash St', 'Austin', 'TX', '73301', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(12, 'Jennifer', 'Thomas', 'jennifer.t@email.com', '555-0112', '1984-02-11', '234-56-7901', '963 Poplar Ave', 'Jacksonville', 'FL', '32201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(13, 'Richard', 'Jackson', 'richard.j@email.com', '555-0113', '1988-08-03', '345-67-9012', '159 Magnolia Dr', 'Fort Worth', 'TX', '76101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(14, 'Patricia', 'White', 'patricia.w@email.com', '555-0114', '1994-11-16', '456-78-0123', '357 Dogwood Ln', 'Columbus', 'OH', '43201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(15, 'Joseph', 'Harris', 'joseph.h@email.com', '555-0115', '1982-05-29', '567-89-1234', '741 Redwood Way', 'Charlotte', 'NC', '28201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(16, 'Linda', 'Martin', 'linda.martin@email.com', '555-0116', '1996-09-01', '678-90-2345', '852 Sequoia Ct', 'San Francisco', 'CA', '94101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(17, 'Thomas', 'Thompson', 'thomas.t@email.com', '555-0117', '1981-01-24', '789-01-3456', '963 Cypress Pl', 'Indianapolis', 'IN', '46201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(18, 'Barbara', 'Garcia', 'barbara.g@email.com', '555-0118', '1987-07-13', '890-12-4567', '147 Fir Blvd', 'Seattle', 'WA', '98101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(19, 'Charles', 'Martinez', 'charles.m@email.com', '555-0119', '1992-03-06', '901-23-5678', '258 Hemlock St', 'Denver', 'CO', '80201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(20, 'Susan', 'Robinson', 'susan.r@email.com', '555-0120', '1985-11-19', '012-34-6789', '369 Larch Ave', 'Washington', 'DC', '20001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(21, 'Christopher', 'Clark', 'chris.c@email.com', '555-0121', '1989-05-02', '123-45-7890', '741 Hickory Dr', 'Boston', 'MA', '02101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(22, 'Jessica', 'Rodriguez', 'jessica.r@email.com', '555-0122', '1991-12-25', '234-56-8901', '852 Walnut Ln', 'El Paso', 'TX', '79901', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(23, 'Daniel', 'Lewis', 'daniel.lewis@email.com', '555-0123', '1983-08-08', '345-67-9012', '963 Chestnut Way', 'Detroit', 'MI', '48201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(24, 'Karen', 'Lee', 'karen.lee@email.com', '555-0124', '1986-04-21', '456-78-0123', '159 Sycamore Ct', 'Nashville', 'TN', '37201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(25, 'Matthew', 'Walker', 'matthew.w@email.com', '555-0125', '1994-10-14', '567-89-1234', '357 Beech Pl', 'Portland', 'OR', '97201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(26, 'Nancy', 'Hall', 'nancy.hall@email.com', '555-0126', '1982-06-27', '678-90-2345', '741 Alder Blvd', 'Oklahoma City', 'OK', '73101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(27, 'Anthony', 'Allen', 'anthony.a@email.com', '555-0127', '1988-02-09', '789-01-3456', '852 Hazel St', 'Las Vegas', 'NV', '89101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(28, 'Betty', 'Young', 'betty.young@email.com', '555-0128', '1995-09-22', '890-12-4567', '963 Locust Ave', 'Memphis', 'TN', '38101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(29, 'Mark', 'Hernandez', 'mark.h@email.com', '555-0129', '1981-03-15', '901-23-5678', '147 Acacia Dr', 'Louisville', 'KY', '40201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(30, 'Sandra', 'King', 'sandra.king@email.com', '555-0130', '1987-11-28', '012-34-6789', '258 Hawthorn Ln', 'Baltimore', 'MD', '21201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(31, 'Donald', 'Wright', 'donald.w@email.com', '555-0131', '1993-07-11', '123-45-7890', '369 Juniper Way', 'Milwaukee', 'WI', '53201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(32, 'Donna', 'Lopez', 'donna.lopez@email.com', '555-0132', '1984-01-04', '234-56-8901', '741 Mulberry Ct', 'Albuquerque', 'NM', '87101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(33, 'Steven', 'Hill', 'steven.hill@email.com', '555-0133', '1989-08-17', '345-67-9012', '852 Eucalyptus Pl', 'Tucson', 'AZ', '85701', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(34, 'Carol', 'Scott', 'carol.scott@email.com', '555-0134', '1992-04-30', '456-78-0123', '963 Olive Blvd', 'Fresno', 'CA', '93701', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(35, 'Paul', 'Green', 'paul.green@email.com', '555-0135', '1986-12-23', '567-89-1234', '159 Palm St', 'Sacramento', 'CA', '95801', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(36, 'Michelle', 'Adams', 'michelle.a@email.com', '555-0136', '1994-06-06', '678-90-2345', '357 Bamboo Ave', 'Kansas City', 'MO', '64101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(37, 'Andrew', 'Baker', 'andrew.b@email.com', '555-0137', '1982-02-19', '789-01-3456', '741 Willow Dr', 'Mesa', 'AZ', '85201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(38, 'Kimberly', 'Gonzalez', 'kimberly.g@email.com', '555-0138', '1988-10-02', '890-12-4567', '852 Aspen Ln', 'Atlanta', 'GA', '30301', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(39, 'Kenneth', 'Nelson', 'kenneth.n@email.com', '555-0139', '1995-04-15', '901-23-5678', '963 Cedar Way', 'Omaha', 'NE', '68101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(40, 'Deborah', 'Carter', 'deborah.c@email.com', '555-0140', '1981-11-28', '012-34-6789', '147 Pine Ct', 'Raleigh', 'NC', '27601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(41, 'Joshua', 'Mitchell', 'joshua.m@email.com', '555-0141', '1987-07-11', '123-45-7890', '258 Oak Pl', 'Miami', 'FL', '33101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(42, 'Dorothy', 'Perez', 'dorothy.p@email.com', '555-0142', '1993-01-24', '234-56-8901', '369 Maple Blvd', 'Long Beach', 'CA', '90801', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(43, 'Kevin', 'Roberts', 'kevin.r@email.com', '555-0143', '1984-09-07', '345-67-9012', '741 Elm St', 'Virginia Beach', 'VA', '23451', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(44, 'Amy', 'Turner', 'amy.turner@email.com', '555-0144', '1989-05-20', '456-78-0123', '852 Birch Ave', 'Oakland', 'CA', '94601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(45, 'Brian', 'Phillips', 'brian.p@email.com', '555-0145', '1992-12-13', '567-89-1234', '963 Spruce Dr', 'Minneapolis', 'MN', '55401', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(46, 'Angela', 'Campbell', 'angela.c@email.com', '555-0146', '1986-08-26', '678-90-2345', '159 Dogwood Ln', 'Tulsa', 'OK', '74101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(47, 'George', 'Parker', 'george.parker@email.com', '555-0147', '1994-04-09', '789-01-3456', '357 Redwood Way', 'Cleveland', 'OH', '44101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(48, 'Ashley', 'Evans', 'ashley.evans@email.com', '555-0148', '1982-10-22', '890-12-4567', '741 Sequoia Ct', 'Wichita', 'KS', '67201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(49, 'Edward', 'Edwards', 'edward.e@email.com', '555-0149', '1988-06-05', '901-23-5678', '852 Cypress Pl', 'Arlington', 'TX', '76001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(50, 'Melissa', 'Collins', 'melissa.c@email.com', '555-0150', '1995-12-18', '012-34-6789', '963 Fir Blvd', 'New Orleans', 'LA', '70112', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- Table 2.2: Payment Card Data (PCI - Payment Card Industry)
CREATE OR REPLACE TABLE payment_cards_pci (
    card_id INT,
    customer_id INT,
    card_number VARCHAR(19),
    card_type VARCHAR(20),
    cardholder_name VARCHAR(100),
    expiration_date VARCHAR(7),
    cvv VARCHAR(4),
    billing_address VARCHAR(200),
    card_status VARCHAR(20),
    issue_date DATE,
    created_at TIMESTAMP
);

INSERT INTO payment_cards_pci VALUES
(1, 1, '4532-1234-5678-9010', 'VISA', 'John Smith', '12/25', '123', '123 Main St, New York, NY 10001', 'ACTIVE', '2020-01-15', CURRENT_TIMESTAMP()),
(2, 2, '5555-1234-5678-9011', 'MASTERCARD', 'Jane Doe', '06/26', '456', '456 Oak Ave, Los Angeles, CA 90001', 'ACTIVE', '2021-02-20', CURRENT_TIMESTAMP()),
(3, 3, '3789-123456-78901', 'AMEX', 'Michael Johnson', '09/27', '789', '789 Pine Rd, Chicago, IL 60601', 'ACTIVE', '2020-03-10', CURRENT_TIMESTAMP()),
(4, 4, '6011-1234-5678-9012', 'DISCOVER', 'Emily Williams', '03/28', '234', '321 Elm St, Houston, TX 77001', 'ACTIVE', '2021-04-05', CURRENT_TIMESTAMP()),
(5, 5, '4532-9876-5432-1098', 'VISA', 'David Brown', '11/25', '567', '654 Maple Dr, Phoenix, AZ 85001', 'ACTIVE', '2020-05-22', CURRENT_TIMESTAMP()),
(6, 6, '5555-9876-5432-1099', 'MASTERCARD', 'Sarah Davis', '07/26', '890', '987 Cedar Ln, Philadelphia, PA 19101', 'ACTIVE', '2021-06-18', CURRENT_TIMESTAMP()),
(7, 7, '3789-987654-32109', 'AMEX', 'Robert Miller', '12/27', '012', '147 Birch Way, San Antonio, TX 78201', 'ACTIVE', '2020-07-14', CURRENT_TIMESTAMP()),
(8, 8, '6011-9876-5432-1100', 'DISCOVER', 'Lisa Wilson', '05/28', '345', '258 Spruce Ct, San Diego, CA 92101', 'ACTIVE', '2021-08-09', CURRENT_TIMESTAMP()),
(9, 9, '4532-2468-1357-9024', 'VISA', 'James Moore', '08/25', '678', '369 Willow Pl, Dallas, TX 75201', 'ACTIVE', '2020-09-30', CURRENT_TIMESTAMP()),
(10, 10, '5555-2468-1357-9025', 'MASTERCARD', 'Mary Taylor', '02/26', '901', '741 Cherry Blvd, San Jose, CA 95101', 'ACTIVE', '2021-10-25', CURRENT_TIMESTAMP()),
(11, 11, '3789-246813-57902', 'AMEX', 'William Anderson', '10/27', '234', '852 Ash St, Austin, TX 73301', 'ACTIVE', '2020-11-21', CURRENT_TIMESTAMP()),
(12, 12, '6011-2468-1357-9026', 'DISCOVER', 'Jennifer Thomas', '04/28', '567', '963 Poplar Ave, Jacksonville, FL 32201', 'ACTIVE', '2021-12-16', CURRENT_TIMESTAMP()),
(13, 13, '4532-3691-4702-5803', 'VISA', 'Richard Jackson', '01/25', '890', '159 Magnolia Dr, Fort Worth, TX 76101', 'ACTIVE', '2020-01-11', CURRENT_TIMESTAMP()),
(14, 14, '5555-3691-4702-5804', 'MASTERCARD', 'Patricia White', '09/26', '123', '357 Dogwood Ln, Columbus, OH 43201', 'ACTIVE', '2021-02-06', CURRENT_TIMESTAMP()),
(15, 15, '3789-369147-02580', 'AMEX', 'Joseph Harris', '06/27', '456', '741 Redwood Way, Charlotte, NC 28201', 'ACTIVE', '2020-03-03', CURRENT_TIMESTAMP()),
(16, 16, '6011-3691-4702-5805', 'DISCOVER', 'Linda Martin', '11/28', '789', '852 Sequoia Ct, San Francisco, CA 94101', 'ACTIVE', '2021-03-29', CURRENT_TIMESTAMP()),
(17, 17, '4532-4702-5813-6904', 'VISA', 'Thomas Thompson', '03/25', '234', '963 Cypress Pl, Indianapolis, IN 46201', 'ACTIVE', '2020-04-24', CURRENT_TIMESTAMP()),
(18, 18, '5555-4702-5813-6905', 'MASTERCARD', 'Barbara Garcia', '07/26', '567', '147 Fir Blvd, Seattle, WA 98101', 'ACTIVE', '2021-05-19', CURRENT_TIMESTAMP()),
(19, 19, '3789-470258-13690', 'AMEX', 'Charles Martinez', '12/27', '890', '258 Hemlock St, Denver, CO 80201', 'ACTIVE', '2020-06-14', CURRENT_TIMESTAMP()),
(20, 20, '6011-4702-5813-6906', 'DISCOVER', 'Susan Robinson', '05/28', '012', '369 Larch Ave, Washington, DC 20001', 'ACTIVE', '2021-07-09', CURRENT_TIMESTAMP()),
(21, 21, '4532-5813-6904-7015', 'VISA', 'Christopher Clark', '08/25', '345', '741 Hickory Dr, Boston, MA 02101', 'ACTIVE', '2020-08-04', CURRENT_TIMESTAMP()),
(22, 22, '5555-5813-6904-7016', 'MASTERCARD', 'Jessica Rodriguez', '02/26', '678', '852 Walnut Ln, El Paso, TX 79901', 'ACTIVE', '2021-08-29', CURRENT_TIMESTAMP()),
(23, 23, '3789-581369-04701', 'AMEX', 'Daniel Lewis', '10/27', '901', '963 Chestnut Way, Detroit, MI 48201', 'ACTIVE', '2020-09-24', CURRENT_TIMESTAMP()),
(24, 24, '6011-5813-6904-7017', 'DISCOVER', 'Karen Lee', '04/28', '234', '159 Sycamore Ct, Nashville, TN 37201', 'ACTIVE', '2021-10-19', CURRENT_TIMESTAMP()),
(25, 25, '4532-6904-7015-8126', 'VISA', 'Matthew Walker', '01/25', '567', '357 Beech Pl, Portland, OR 97201', 'ACTIVE', '2020-11-14', CURRENT_TIMESTAMP()),
(26, 26, '5555-6904-7015-8127', 'MASTERCARD', 'Nancy Hall', '09/26', '890', '741 Alder Blvd, Oklahoma City, OK 73101', 'ACTIVE', '2021-12-09', CURRENT_TIMESTAMP()),
(27, 27, '3789-690470-15812', 'AMEX', 'Anthony Allen', '06/27', '123', '852 Hazel St, Las Vegas, NV 89101', 'ACTIVE', '2020-01-04', CURRENT_TIMESTAMP()),
(28, 28, '6011-6904-7015-8128', 'DISCOVER', 'Betty Young', '11/28', '456', '963 Locust Ave, Memphis, TN 38101', 'ACTIVE', '2021-01-29', CURRENT_TIMESTAMP()),
(29, 29, '4532-7015-8126-9237', 'VISA', 'Mark Hernandez', '03/25', '789', '147 Acacia Dr, Louisville, KY 40201', 'ACTIVE', '2020-02-23', CURRENT_TIMESTAMP()),
(30, 30, '5555-7015-8126-9238', 'MASTERCARD', 'Sandra King', '07/26', '234', '258 Hawthorn Ln, Baltimore, MD 21201', 'ACTIVE', '2021-03-20', CURRENT_TIMESTAMP()),
(31, 31, '3789-701581-26923', 'AMEX', 'Donald Wright', '12/27', '567', '369 Juniper Way, Milwaukee, WI 53201', 'ACTIVE', '2020-04-15', CURRENT_TIMESTAMP()),
(32, 32, '6011-7015-8126-9239', 'DISCOVER', 'Donna Lopez', '05/28', '890', '741 Mulberry Ct, Albuquerque, NM 87101', 'ACTIVE', '2021-05-10', CURRENT_TIMESTAMP()),
(33, 33, '4532-8126-9237-0348', 'VISA', 'Steven Hill', '08/25', '012', '852 Eucalyptus Pl, Tucson, AZ 85701', 'ACTIVE', '2020-06-05', CURRENT_TIMESTAMP()),
(34, 34, '5555-8126-9237-0349', 'MASTERCARD', 'Carol Scott', '02/26', '345', '963 Olive Blvd, Fresno, CA 93701', 'ACTIVE', '2021-06-30', CURRENT_TIMESTAMP()),
(35, 35, '3789-812692-37034', 'AMEX', 'Paul Green', '10/27', '678', '159 Palm St, Sacramento, CA 95801', 'ACTIVE', '2020-07-25', CURRENT_TIMESTAMP()),
(36, 36, '6011-8126-9237-0350', 'DISCOVER', 'Michelle Adams', '04/28', '901', '357 Bamboo Ave, Kansas City, MO 64101', 'ACTIVE', '2021-08-20', CURRENT_TIMESTAMP()),
(37, 37, '4532-9237-0348-1459', 'VISA', 'Andrew Baker', '01/25', '234', '741 Willow Dr, Mesa, AZ 85201', 'ACTIVE', '2020-09-15', CURRENT_TIMESTAMP()),
(38, 38, '5555-9237-0348-1460', 'MASTERCARD', 'Kimberly Gonzalez', '09/26', '567', '852 Aspen Ln, Atlanta, GA 30301', 'ACTIVE', '2021-10-10', CURRENT_TIMESTAMP()),
(39, 39, '3789-923703-48145', 'AMEX', 'Kenneth Nelson', '06/27', '890', '963 Cedar Way, Omaha, NE 68101', 'ACTIVE', '2020-11-05', CURRENT_TIMESTAMP()),
(40, 40, '6011-9237-0348-1461', 'DISCOVER', 'Deborah Carter', '11/28', '123', '147 Pine Ct, Raleigh, NC 27601', 'ACTIVE', '2021-11-30', CURRENT_TIMESTAMP()),
(41, 41, '4532-0348-1459-2570', 'VISA', 'Joshua Mitchell', '03/25', '456', '258 Oak Pl, Miami, FL 33101', 'ACTIVE', '2020-12-25', CURRENT_TIMESTAMP()),
(42, 42, '5555-0348-1459-2571', 'MASTERCARD', 'Dorothy Perez', '07/26', '789', '369 Maple Blvd, Long Beach, CA 90801', 'ACTIVE', '2022-01-19', CURRENT_TIMESTAMP()),
(43, 43, '3789-034814-59257', 'AMEX', 'Kevin Roberts', '12/27', '234', '741 Elm St, Virginia Beach, VA 23451', 'ACTIVE', '2021-02-14', CURRENT_TIMESTAMP()),
(44, 44, '6011-0348-1459-2572', 'DISCOVER', 'Amy Turner', '05/28', '567', '852 Birch Ave, Oakland, CA 94601', 'ACTIVE', '2022-03-11', CURRENT_TIMESTAMP()),
(45, 45, '4532-1459-2570-3681', 'VISA', 'Brian Phillips', '08/25', '890', '963 Spruce Dr, Minneapolis, MN 55401', 'ACTIVE', '2021-04-06', CURRENT_TIMESTAMP()),
(46, 46, '5555-1459-2570-3682', 'MASTERCARD', 'Angela Campbell', '02/26', '012', '159 Dogwood Ln, Tulsa, OK 74101', 'ACTIVE', '2022-05-01', CURRENT_TIMESTAMP()),
(47, 47, '3789-145925-70368', 'AMEX', 'George Parker', '10/27', '345', '357 Redwood Way, Cleveland, OH 44101', 'ACTIVE', '2021-05-27', CURRENT_TIMESTAMP()),
(48, 48, '6011-1459-2570-3683', 'DISCOVER', 'Ashley Evans', '04/28', '678', '741 Sequoia Ct, Wichita, KS 67201', 'ACTIVE', '2022-06-21', CURRENT_TIMESTAMP()),
(49, 49, '4532-2570-3681-4792', 'VISA', 'Edward Edwards', '01/25', '901', '852 Cypress Pl, Arlington, TX 76001', 'ACTIVE', '2021-07-16', CURRENT_TIMESTAMP()),
(50, 50, '5555-2570-3681-4793', 'MASTERCARD', 'Melissa Collins', '09/26', '234', '963 Fir Blvd, New Orleans, LA 70112', 'ACTIVE', '2022-08-11', CURRENT_TIMESTAMP());

-- Table 2.3: Account Numbers (PAN - Primary Account Number)
CREATE OR REPLACE TABLE account_numbers_pan (
    account_id INT,
    customer_id INT,
    account_number VARCHAR(20),
    account_type VARCHAR(20),
    routing_number VARCHAR(9),
    bank_name VARCHAR(100),
    account_status VARCHAR(20),
    balance DECIMAL(15,2),
    opened_date DATE,
    created_at TIMESTAMP
);

INSERT INTO account_numbers_pan VALUES
(1, 1, '1234567890123456', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 12500.50, '2020-01-15', CURRENT_TIMESTAMP()),
(2, 2, '2345678901234567', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 25430.75, '2021-02-20', CURRENT_TIMESTAMP()),
(3, 3, '3456789012345678', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 8750.25, '2020-03-10', CURRENT_TIMESTAMP()),
(4, 4, '4567890123456789', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 42100.00, '2021-04-05', CURRENT_TIMESTAMP()),
(5, 5, '5678901234567890', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 15230.60, '2020-05-22', CURRENT_TIMESTAMP()),
(6, 6, '6789012345678901', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 38250.90, '2021-06-18', CURRENT_TIMESTAMP()),
(7, 7, '7890123456789012', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 9875.40, '2020-07-14', CURRENT_TIMESTAMP()),
(8, 8, '8901234567890123', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 52340.15, '2021-08-09', CURRENT_TIMESTAMP()),
(9, 9, '9012345678901234', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 18320.80, '2020-09-30', CURRENT_TIMESTAMP()),
(10, 10, '0123456789012345', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 46980.35, '2021-10-25', CURRENT_TIMESTAMP()),
(11, 11, '1111222233334444', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 21450.70, '2020-11-21', CURRENT_TIMESTAMP()),
(12, 12, '2222333344445555', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 57120.95, '2021-12-16', CURRENT_TIMESTAMP()),
(13, 13, '3333444455556666', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 12980.25, '2020-01-11', CURRENT_TIMESTAMP()),
(14, 14, '4444555566667777', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 39850.60, '2021-02-06', CURRENT_TIMESTAMP()),
(15, 15, '5555666677778888', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 17240.85, '2020-03-03', CURRENT_TIMESTAMP()),
(16, 16, '6666777788889999', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 61430.20, '2021-03-29', CURRENT_TIMESTAMP()),
(17, 17, '7777888899990000', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 11560.45, '2020-04-24', CURRENT_TIMESTAMP()),
(18, 18, '8888999900001111', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 48720.80, '2021-05-19', CURRENT_TIMESTAMP()),
(19, 19, '9999000011112222', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 19580.15, '2020-06-14', CURRENT_TIMESTAMP()),
(20, 20, '0000111122223333', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 55240.50, '2021-07-09', CURRENT_TIMESTAMP()),
(21, 21, '1111222233334445', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 22100.90, '2020-08-04', CURRENT_TIMESTAMP()),
(22, 22, '2222333344445556', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 59350.25, '2021-08-29', CURRENT_TIMESTAMP()),
(23, 23, '3333444455556667', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 13870.60, '2020-09-24', CURRENT_TIMESTAMP()),
(24, 24, '4444555566667778', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 62840.75, '2021-10-19', CURRENT_TIMESTAMP()),
(25, 25, '5555666677778889', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 16250.30, '2020-11-14', CURRENT_TIMESTAMP()),
(26, 26, '6666777788889990', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 51780.95, '2021-12-09', CURRENT_TIMESTAMP()),
(27, 27, '7777888899990001', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 12430.40, '2020-01-04', CURRENT_TIMESTAMP()),
(28, 28, '8888999900001112', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 64920.10, '2021-01-29', CURRENT_TIMESTAMP()),
(29, 29, '9999000011112223', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 17890.55, '2020-02-23', CURRENT_TIMESTAMP()),
(30, 30, '0000111122223334', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 58450.85, '2021-03-20', CURRENT_TIMESTAMP()),
(31, 31, '1111222233334446', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 19640.20, '2020-04-15', CURRENT_TIMESTAMP()),
(32, 32, '2222333344445557', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 61280.45, '2021-05-10', CURRENT_TIMESTAMP()),
(33, 33, '3333444455556668', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 14260.70, '2020-06-05', CURRENT_TIMESTAMP()),
(34, 34, '4444555566667779', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 53790.95, '2021-06-30', CURRENT_TIMESTAMP()),
(35, 35, '5555666677778890', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 15780.25, '2020-07-25', CURRENT_TIMESTAMP()),
(36, 36, '6666777788889991', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 66120.50, '2021-08-20', CURRENT_TIMESTAMP()),
(37, 37, '7777888899990002', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 11950.80, '2020-09-15', CURRENT_TIMESTAMP()),
(38, 38, '8888999900001113', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 57640.15, '2021-10-10', CURRENT_TIMESTAMP()),
(39, 39, '9999000011112224', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 18320.40, '2020-11-05', CURRENT_TIMESTAMP()),
(40, 40, '0000111122223335', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 63580.65, '2021-11-30', CURRENT_TIMESTAMP()),
(41, 41, '1111222233334447', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 20560.90, '2020-12-25', CURRENT_TIMESTAMP()),
(42, 42, '2222333344445558', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 59120.35, '2022-01-19', CURRENT_TIMESTAMP()),
(43, 43, '3333444455556669', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 13470.60, '2021-02-14', CURRENT_TIMESTAMP()),
(44, 44, '4444555566667780', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 68840.80, '2022-03-11', CURRENT_TIMESTAMP()),
(45, 45, '5555666677778891', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 16930.15, '2021-04-06', CURRENT_TIMESTAMP()),
(46, 46, '6666777788889992', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 61950.40, '2022-05-01', CURRENT_TIMESTAMP()),
(47, 47, '7777888899990003', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 14890.70, '2021-05-27', CURRENT_TIMESTAMP()),
(48, 48, '8888999900001114', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 67280.95, '2022-06-21', CURRENT_TIMESTAMP()),
(49, 49, '9999000011112225', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 19140.20, '2021-07-16', CURRENT_TIMESTAMP()),
(50, 50, '0000111122223336', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 65320.55, '2022-08-11', CURRENT_TIMESTAMP());

-- Grant permissions on base tables
GRANT SELECT ON manual_classification.raw_data.customers_pii TO ROLE analyst;
GRANT SELECT ON manual_classification.raw_data.customers_pii TO ROLE limited_user;
GRANT SELECT ON manual_classification.raw_data.customers_pii TO ROLE data_steward;
GRANT SELECT ON manual_classification.raw_data.payment_cards_pci TO ROLE analyst;
GRANT SELECT ON manual_classification.raw_data.payment_cards_pci TO ROLE limited_user;
GRANT SELECT ON manual_classification.raw_data.payment_cards_pci TO ROLE data_steward;
GRANT SELECT ON manual_classification.raw_data.account_numbers_pan TO ROLE analyst;
GRANT SELECT ON manual_classification.raw_data.account_numbers_pan TO ROLE limited_user;
GRANT SELECT ON manual_classification.raw_data.account_numbers_pan TO ROLE data_steward;

-- ============================================================================
-- SECTION 2B: AUTO CLASSIFICATION DATABASE - BASE TABLES WITH SAMPLE DATA (50 ROWS EACH)
-- ============================================================================

USE DATABASE auto_classification;
USE SCHEMA raw_data;

-- Table 2B.1: Customer PII Data (Personal Identifiable Information)
CREATE OR REPLACE TABLE customers_pii (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    social_security_number VARCHAR(11),
    address_line1 VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

INSERT INTO customers_pii VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@email.com', '555-0201', '1985-03-15', '123-45-6789', '123 Main St', 'New York', 'NY', '10001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(2, 'Bob', 'Williams', 'bob.williams@email.com', '555-0202', '1990-07-22', '234-56-7890', '456 Oak Ave', 'Los Angeles', 'CA', '90001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(3, 'Carol', 'Brown', 'carol.brown@email.com', '555-0203', '1978-11-30', '345-67-8901', '789 Pine Rd', 'Chicago', 'IL', '60601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(4, 'David', 'Jones', 'david.jones@email.com', '555-0204', '1992-05-18', '456-78-9012', '321 Elm St', 'Houston', 'TX', '77001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(5, 'Eva', 'Garcia', 'eva.garcia@email.com', '555-0205', '1987-09-25', '567-89-0123', '654 Maple Dr', 'Phoenix', 'AZ', '85001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(6, 'Frank', 'Miller', 'frank.miller@email.com', '555-0206', '1995-01-12', '678-90-1234', '987 Cedar Ln', 'Philadelphia', 'PA', '19101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(7, 'Grace', 'Davis', 'grace.davis@email.com', '555-0207', '1983-08-05', '789-01-2345', '147 Birch Way', 'San Antonio', 'TX', '78201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(8, 'Henry', 'Rodriguez', 'henry.r@email.com', '555-0208', '1989-12-28', '890-12-3456', '258 Spruce Ct', 'San Diego', 'CA', '92101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(9, 'Iris', 'Martinez', 'iris.martinez@email.com', '555-0209', '1991-04-14', '901-23-4567', '369 Willow Pl', 'Dallas', 'TX', '75201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(10, 'Jack', 'Hernandez', 'jack.h@email.com', '555-0210', '1986-10-07', '012-34-5678', '741 Cherry Blvd', 'San Jose', 'CA', '95101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(11, 'Kate', 'Lopez', 'kate.lopez@email.com', '555-0211', '1993-06-20', '123-45-6790', '852 Ash St', 'Austin', 'TX', '73301', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(12, 'Liam', 'Wilson', 'liam.wilson@email.com', '555-0212', '1984-02-11', '234-56-7901', '963 Poplar Ave', 'Jacksonville', 'FL', '32201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(13, 'Maya', 'Anderson', 'maya.a@email.com', '555-0213', '1988-08-03', '345-67-9012', '159 Magnolia Dr', 'Fort Worth', 'TX', '76101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(14, 'Noah', 'Thomas', 'noah.thomas@email.com', '555-0214', '1994-11-16', '456-78-0123', '357 Dogwood Ln', 'Columbus', 'OH', '43201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(15, 'Olivia', 'Taylor', 'olivia.taylor@email.com', '555-0215', '1982-05-29', '567-89-1234', '741 Redwood Way', 'Charlotte', 'NC', '28201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(16, 'Paul', 'Moore', 'paul.moore@email.com', '555-0216', '1996-09-01', '678-90-2345', '852 Sequoia Ct', 'San Francisco', 'CA', '94101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(17, 'Quinn', 'Jackson', 'quinn.jackson@email.com', '555-0217', '1981-01-24', '789-01-3456', '963 Cypress Pl', 'Indianapolis', 'IN', '46201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(18, 'Rachel', 'White', 'rachel.white@email.com', '555-0218', '1987-07-13', '890-12-4567', '147 Fir Blvd', 'Seattle', 'WA', '98101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(19, 'Sam', 'Harris', 'sam.harris@email.com', '555-0219', '1992-03-06', '901-23-5678', '258 Hemlock St', 'Denver', 'CO', '80201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(20, 'Tara', 'Martin', 'tara.martin@email.com', '555-0220', '1985-11-19', '012-34-6789', '369 Larch Ave', 'Washington', 'DC', '20001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(21, 'Uma', 'Thompson', 'uma.thompson@email.com', '555-0221', '1989-05-02', '123-45-7890', '741 Hickory Dr', 'Boston', 'MA', '02101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(22, 'Victor', 'Garcia', 'victor.garcia@email.com', '555-0222', '1991-12-25', '234-56-8901', '852 Walnut Ln', 'El Paso', 'TX', '79901', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(23, 'Wendy', 'Martinez', 'wendy.martinez@email.com', '555-0223', '1983-08-08', '345-67-9012', '963 Chestnut Way', 'Detroit', 'MI', '48201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(24, 'Xavier', 'Robinson', 'xavier.r@email.com', '555-0224', '1986-04-21', '456-78-0123', '159 Sycamore Ct', 'Nashville', 'TN', '37201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(25, 'Yara', 'Clark', 'yara.clark@email.com', '555-0225', '1994-10-14', '567-89-1234', '357 Beech Pl', 'Portland', 'OR', '97201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(26, 'Zane', 'Rodriguez', 'zane.rodriguez@email.com', '555-0226', '1982-06-27', '678-90-2345', '741 Alder Blvd', 'Oklahoma City', 'OK', '73101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(27, 'Aria', 'Lewis', 'aria.lewis@email.com', '555-0227', '1988-02-09', '789-01-3456', '852 Hazel St', 'Las Vegas', 'NV', '89101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(28, 'Ben', 'Lee', 'ben.lee@email.com', '555-0228', '1995-09-22', '890-12-4567', '963 Locust Ave', 'Memphis', 'TN', '38101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(29, 'Cora', 'Walker', 'cora.walker@email.com', '555-0229', '1981-03-15', '901-23-5678', '147 Acacia Dr', 'Louisville', 'KY', '40201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(30, 'Drew', 'Hall', 'drew.hall@email.com', '555-0230', '1987-11-28', '012-34-6789', '258 Hawthorn Ln', 'Baltimore', 'MD', '21201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(31, 'Ella', 'Allen', 'ella.allen@email.com', '555-0231', '1993-07-11', '123-45-7890', '369 Juniper Way', 'Milwaukee', 'WI', '53201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(32, 'Finn', 'Young', 'finn.young@email.com', '555-0232', '1984-01-04', '234-56-8901', '741 Mulberry Ct', 'Albuquerque', 'NM', '87101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(33, 'Gina', 'Hernandez', 'gina.hernandez@email.com', '555-0233', '1989-08-17', '345-67-9012', '852 Eucalyptus Pl', 'Tucson', 'AZ', '85701', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(34, 'Hank', 'King', 'hank.king@email.com', '555-0234', '1992-04-30', '456-78-0123', '963 Olive Blvd', 'Fresno', 'CA', '93701', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(35, 'Ivy', 'Wright', 'ivy.wright@email.com', '555-0235', '1986-12-23', '567-89-1234', '159 Palm St', 'Sacramento', 'CA', '95801', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(36, 'Jake', 'Lopez', 'jake.lopez@email.com', '555-0236', '1994-06-06', '678-90-2345', '357 Bamboo Ave', 'Kansas City', 'MO', '64101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(37, 'Kara', 'Hill', 'kara.hill@email.com', '555-0237', '1982-02-19', '789-01-3456', '741 Willow Dr', 'Mesa', 'AZ', '85201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(38, 'Luke', 'Scott', 'luke.scott@email.com', '555-0238', '1988-10-02', '890-12-4567', '852 Aspen Ln', 'Atlanta', 'GA', '30301', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(39, 'Mia', 'Green', 'mia.green@email.com', '555-0239', '1995-04-15', '901-23-5678', '963 Cedar Way', 'Omaha', 'NE', '68101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(40, 'Nate', 'Adams', 'nate.adams@email.com', '555-0240', '1981-11-28', '012-34-6789', '147 Pine Ct', 'Raleigh', 'NC', '27601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(41, 'Owen', 'Baker', 'owen.baker@email.com', '555-0241', '1987-07-11', '123-45-7890', '258 Oak Pl', 'Miami', 'FL', '33101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(42, 'Pam', 'Gonzalez', 'pam.gonzalez@email.com', '555-0242', '1993-01-24', '234-56-8901', '369 Maple Blvd', 'Long Beach', 'CA', '90801', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(43, 'Quinn', 'Nelson', 'quinn.nelson@email.com', '555-0243', '1984-09-07', '345-67-9012', '741 Elm St', 'Virginia Beach', 'VA', '23451', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(44, 'Rose', 'Carter', 'rose.carter@email.com', '555-0244', '1989-05-20', '456-78-0123', '852 Birch Ave', 'Oakland', 'CA', '94601', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(45, 'Sean', 'Mitchell', 'sean.mitchell@email.com', '555-0245', '1992-12-13', '567-89-1234', '963 Spruce Dr', 'Minneapolis', 'MN', '55401', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(46, 'Tess', 'Perez', 'tess.perez@email.com', '555-0246', '1986-08-26', '678-90-2345', '159 Dogwood Ln', 'Tulsa', 'OK', '74101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(47, 'Ursa', 'Roberts', 'ursa.roberts@email.com', '555-0247', '1994-04-09', '789-01-3456', '357 Redwood Way', 'Cleveland', 'OH', '44101', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(48, 'Vera', 'Turner', 'vera.turner@email.com', '555-0248', '1982-10-22', '890-12-4567', '741 Sequoia Ct', 'Wichita', 'KS', '67201', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(49, 'Wade', 'Phillips', 'wade.phillips@email.com', '555-0249', '1988-06-05', '901-23-5678', '852 Cypress Pl', 'Arlington', 'TX', '76001', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
(50, 'Xena', 'Campbell', 'xena.campbell@email.com', '555-0250', '1995-12-18', '012-34-6789', '963 Fir Blvd', 'New Orleans', 'LA', '70112', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- Table 2B.2: Payment Card Data (PCI - Payment Card Industry)
CREATE OR REPLACE TABLE payment_cards_pci (
    card_id INT,
    customer_id INT,
    card_number VARCHAR(19),
    card_type VARCHAR(20),
    cardholder_name VARCHAR(100),
    expiration_date VARCHAR(7),
    cvv VARCHAR(4),
    billing_address VARCHAR(200),
    card_status VARCHAR(20),
    issue_date DATE,
    created_at TIMESTAMP
);

INSERT INTO payment_cards_pci VALUES
(1, 1, '4532-5678-9012-3456', 'VISA', 'Alice Johnson', '12/25', '123', '123 Main St, New York, NY 10001', 'ACTIVE', '2020-01-15', CURRENT_TIMESTAMP()),
(2, 2, '5555-5678-9012-3457', 'MASTERCARD', 'Bob Williams', '06/26', '456', '456 Oak Ave, Los Angeles, CA 90001', 'ACTIVE', '2021-02-20', CURRENT_TIMESTAMP()),
(3, 3, '3789-567890-12345', 'AMEX', 'Carol Brown', '09/27', '789', '789 Pine Rd, Chicago, IL 60601', 'ACTIVE', '2020-03-10', CURRENT_TIMESTAMP()),
(4, 4, '6011-5678-9012-3458', 'DISCOVER', 'David Jones', '03/28', '234', '321 Elm St, Houston, TX 77001', 'ACTIVE', '2021-04-05', CURRENT_TIMESTAMP()),
(5, 5, '4532-1111-2222-3333', 'VISA', 'Eva Garcia', '11/25', '567', '654 Maple Dr, Phoenix, AZ 85001', 'ACTIVE', '2020-05-22', CURRENT_TIMESTAMP()),
(6, 6, '5555-1111-2222-3334', 'MASTERCARD', 'Frank Miller', '07/26', '890', '987 Cedar Ln, Philadelphia, PA 19101', 'ACTIVE', '2021-06-18', CURRENT_TIMESTAMP()),
(7, 7, '3789-111122-22333', 'AMEX', 'Grace Davis', '12/27', '012', '147 Birch Way, San Antonio, TX 78201', 'ACTIVE', '2020-07-14', CURRENT_TIMESTAMP()),
(8, 8, '6011-1111-2222-3335', 'DISCOVER', 'Henry Rodriguez', '05/28', '345', '258 Spruce Ct, San Diego, CA 92101', 'ACTIVE', '2021-08-09', CURRENT_TIMESTAMP()),
(9, 9, '4532-2222-3333-4444', 'VISA', 'Iris Martinez', '08/25', '678', '369 Willow Pl, Dallas, TX 75201', 'ACTIVE', '2020-09-30', CURRENT_TIMESTAMP()),
(10, 10, '5555-2222-3333-4445', 'MASTERCARD', 'Jack Hernandez', '02/26', '901', '741 Cherry Blvd, San Jose, CA 95101', 'ACTIVE', '2021-10-25', CURRENT_TIMESTAMP()),
(11, 11, '3789-222233-33444', 'AMEX', 'Kate Lopez', '10/27', '234', '852 Ash St, Austin, TX 73301', 'ACTIVE', '2020-11-21', CURRENT_TIMESTAMP()),
(12, 12, '6011-2222-3333-4446', 'DISCOVER', 'Liam Wilson', '04/28', '567', '963 Poplar Ave, Jacksonville, FL 32201', 'ACTIVE', '2021-12-16', CURRENT_TIMESTAMP()),
(13, 13, '4532-3333-4444-5555', 'VISA', 'Maya Anderson', '01/25', '890', '159 Magnolia Dr, Fort Worth, TX 76101', 'ACTIVE', '2020-01-11', CURRENT_TIMESTAMP()),
(14, 14, '5555-3333-4444-5556', 'MASTERCARD', 'Noah Thomas', '09/26', '123', '357 Dogwood Ln, Columbus, OH 43201', 'ACTIVE', '2021-02-06', CURRENT_TIMESTAMP()),
(15, 15, '3789-333344-44555', 'AMEX', 'Olivia Taylor', '06/27', '456', '741 Redwood Way, Charlotte, NC 28201', 'ACTIVE', '2020-03-03', CURRENT_TIMESTAMP()),
(16, 16, '6011-3333-4444-5557', 'DISCOVER', 'Paul Moore', '11/28', '789', '852 Sequoia Ct, San Francisco, CA 94101', 'ACTIVE', '2021-03-29', CURRENT_TIMESTAMP()),
(17, 17, '4532-4444-5555-6666', 'VISA', 'Quinn Jackson', '03/25', '234', '963 Cypress Pl, Indianapolis, IN 46201', 'ACTIVE', '2020-04-24', CURRENT_TIMESTAMP()),
(18, 18, '5555-4444-5555-6667', 'MASTERCARD', 'Rachel White', '07/26', '567', '147 Fir Blvd, Seattle, WA 98101', 'ACTIVE', '2021-05-19', CURRENT_TIMESTAMP()),
(19, 19, '3789-444455-55666', 'AMEX', 'Sam Harris', '12/27', '890', '258 Hemlock St, Denver, CO 80201', 'ACTIVE', '2020-06-14', CURRENT_TIMESTAMP()),
(20, 20, '6011-4444-5555-6668', 'DISCOVER', 'Tara Martin', '05/28', '012', '369 Larch Ave, Washington, DC 20001', 'ACTIVE', '2021-07-09', CURRENT_TIMESTAMP()),
(21, 21, '4532-5555-6666-7777', 'VISA', 'Uma Thompson', '08/25', '345', '741 Hickory Dr, Boston, MA 02101', 'ACTIVE', '2020-08-04', CURRENT_TIMESTAMP()),
(22, 22, '5555-5555-6666-7778', 'MASTERCARD', 'Victor Garcia', '02/26', '678', '852 Walnut Ln, El Paso, TX 79901', 'ACTIVE', '2021-08-29', CURRENT_TIMESTAMP()),
(23, 23, '3789-555566-66777', 'AMEX', 'Wendy Martinez', '10/27', '901', '963 Chestnut Way, Detroit, MI 48201', 'ACTIVE', '2020-09-24', CURRENT_TIMESTAMP()),
(24, 24, '6011-5555-6666-7779', 'DISCOVER', 'Xavier Robinson', '04/28', '234', '159 Sycamore Ct, Nashville, TN 37201', 'ACTIVE', '2021-10-19', CURRENT_TIMESTAMP()),
(25, 25, '4532-6666-7777-8888', 'VISA', 'Yara Clark', '01/25', '567', '357 Beech Pl, Portland, OR 97201', 'ACTIVE', '2020-11-14', CURRENT_TIMESTAMP()),
(26, 26, '5555-6666-7777-8889', 'MASTERCARD', 'Zane Rodriguez', '09/26', '890', '741 Alder Blvd, Oklahoma City, OK 73101', 'ACTIVE', '2021-12-09', CURRENT_TIMESTAMP()),
(27, 27, '3789-666677-77888', 'AMEX', 'Aria Lewis', '06/27', '123', '852 Hazel St, Las Vegas, NV 89101', 'ACTIVE', '2020-01-04', CURRENT_TIMESTAMP()),
(28, 28, '6011-6666-7777-8890', 'DISCOVER', 'Ben Lee', '11/28', '456', '963 Locust Ave, Memphis, TN 38101', 'ACTIVE', '2021-01-29', CURRENT_TIMESTAMP()),
(29, 29, '4532-7777-8888-9999', 'VISA', 'Cora Walker', '03/25', '789', '147 Acacia Dr, Louisville, KY 40201', 'ACTIVE', '2020-02-23', CURRENT_TIMESTAMP()),
(30, 30, '5555-7777-8888-9990', 'MASTERCARD', 'Drew Hall', '07/26', '234', '258 Hawthorn Ln, Baltimore, MD 21201', 'ACTIVE', '2021-03-20', CURRENT_TIMESTAMP()),
(31, 31, '3789-777888-89990', 'AMEX', 'Ella Allen', '12/27', '567', '369 Juniper Way, Milwaukee, WI 53201', 'ACTIVE', '2020-04-15', CURRENT_TIMESTAMP()),
(32, 32, '6011-7777-8888-9991', 'DISCOVER', 'Finn Young', '05/28', '890', '741 Mulberry Ct, Albuquerque, NM 87101', 'ACTIVE', '2021-05-10', CURRENT_TIMESTAMP()),
(33, 33, '4532-8888-9999-0000', 'VISA', 'Gina Hernandez', '08/25', '012', '852 Eucalyptus Pl, Tucson, AZ 85701', 'ACTIVE', '2020-06-05', CURRENT_TIMESTAMP()),
(34, 34, '5555-8888-9999-0001', 'MASTERCARD', 'Hank King', '02/26', '345', '963 Olive Blvd, Fresno, CA 93701', 'ACTIVE', '2021-06-30', CURRENT_TIMESTAMP()),
(35, 35, '3789-888999-90000', 'AMEX', 'Ivy Wright', '10/27', '678', '159 Palm St, Sacramento, CA 95801', 'ACTIVE', '2020-07-25', CURRENT_TIMESTAMP()),
(36, 36, '6011-8888-9999-0002', 'DISCOVER', 'Jake Lopez', '04/28', '901', '357 Bamboo Ave, Kansas City, MO 64101', 'ACTIVE', '2021-08-20', CURRENT_TIMESTAMP()),
(37, 37, '4532-9999-0000-1111', 'VISA', 'Kara Hill', '01/25', '234', '741 Willow Dr, Mesa, AZ 85201', 'ACTIVE', '2020-09-15', CURRENT_TIMESTAMP()),
(38, 38, '5555-9999-0000-1112', 'MASTERCARD', 'Luke Scott', '09/26', '567', '852 Aspen Ln, Atlanta, GA 30301', 'ACTIVE', '2021-10-10', CURRENT_TIMESTAMP()),
(39, 39, '3789-999000-00111', 'AMEX', 'Mia Green', '06/27', '890', '963 Cedar Way, Omaha, NE 68101', 'ACTIVE', '2020-11-05', CURRENT_TIMESTAMP()),
(40, 40, '6011-9999-0000-1113', 'DISCOVER', 'Nate Adams', '11/28', '123', '147 Pine Ct, Raleigh, NC 27601', 'ACTIVE', '2021-11-30', CURRENT_TIMESTAMP()),
(41, 41, '4532-0000-1111-2222', 'VISA', 'Owen Baker', '03/25', '456', '258 Oak Pl, Miami, FL 33101', 'ACTIVE', '2020-12-25', CURRENT_TIMESTAMP()),
(42, 42, '5555-0000-1111-2223', 'MASTERCARD', 'Pam Gonzalez', '07/26', '789', '369 Maple Blvd, Long Beach, CA 90801', 'ACTIVE', '2022-01-19', CURRENT_TIMESTAMP()),
(43, 43, '3789-000111-12222', 'AMEX', 'Quinn Nelson', '12/27', '234', '741 Elm St, Virginia Beach, VA 23451', 'ACTIVE', '2021-02-14', CURRENT_TIMESTAMP()),
(44, 44, '6011-0000-1111-2224', 'DISCOVER', 'Rose Carter', '05/28', '567', '852 Birch Ave, Oakland, CA 94601', 'ACTIVE', '2022-03-11', CURRENT_TIMESTAMP()),
(45, 45, '4532-1111-2222-3333', 'VISA', 'Sean Mitchell', '08/25', '890', '963 Spruce Dr, Minneapolis, MN 55401', 'ACTIVE', '2021-04-06', CURRENT_TIMESTAMP()),
(46, 46, '5555-1111-2222-3334', 'MASTERCARD', 'Tess Perez', '02/26', '012', '159 Dogwood Ln, Tulsa, OK 74101', 'ACTIVE', '2022-05-01', CURRENT_TIMESTAMP()),
(47, 47, '3789-111222-22333', 'AMEX', 'Ursa Roberts', '10/27', '345', '357 Redwood Way, Cleveland, OH 44101', 'ACTIVE', '2021-05-27', CURRENT_TIMESTAMP()),
(48, 48, '6011-1111-2222-3335', 'DISCOVER', 'Vera Turner', '04/28', '678', '741 Sequoia Ct, Wichita, KS 67201', 'ACTIVE', '2022-06-21', CURRENT_TIMESTAMP()),
(49, 49, '4532-2222-3333-4444', 'VISA', 'Wade Phillips', '01/25', '901', '852 Cypress Pl, Arlington, TX 76001', 'ACTIVE', '2021-07-16', CURRENT_TIMESTAMP()),
(50, 50, '5555-2222-3333-4445', 'MASTERCARD', 'Xena Campbell', '09/26', '234', '963 Fir Blvd, New Orleans, LA 70112', 'ACTIVE', '2022-08-11', CURRENT_TIMESTAMP());

-- Table 2B.3: Account Numbers (PAN - Primary Account Number)
CREATE OR REPLACE TABLE account_numbers_pan (
    account_id INT,
    customer_id INT,
    account_number VARCHAR(20),
    account_type VARCHAR(20),
    routing_number VARCHAR(9),
    bank_name VARCHAR(100),
    account_status VARCHAR(20),
    balance DECIMAL(15,2),
    opened_date DATE,
    created_at TIMESTAMP
);

INSERT INTO account_numbers_pan VALUES
(1, 1, '9876543210987654', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 22500.50, '2020-01-15', CURRENT_TIMESTAMP()),
(2, 2, '8765432109876543', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 35430.75, '2021-02-20', CURRENT_TIMESTAMP()),
(3, 3, '7654321098765432', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 18750.25, '2020-03-10', CURRENT_TIMESTAMP()),
(4, 4, '6543210987654321', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 52100.00, '2021-04-05', CURRENT_TIMESTAMP()),
(5, 5, '5432109876543210', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 25230.60, '2020-05-22', CURRENT_TIMESTAMP()),
(6, 6, '4321098765432109', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 48250.90, '2021-06-18', CURRENT_TIMESTAMP()),
(7, 7, '3210987654321098', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 19875.40, '2020-07-14', CURRENT_TIMESTAMP()),
(8, 8, '2109876543210987', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 62340.15, '2021-08-09', CURRENT_TIMESTAMP()),
(9, 9, '1098765432109876', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 28320.80, '2020-09-30', CURRENT_TIMESTAMP()),
(10, 10, '0987654321098765', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 56980.35, '2021-10-25', CURRENT_TIMESTAMP()),
(11, 11, '9876543210987655', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 31450.70, '2020-11-21', CURRENT_TIMESTAMP()),
(12, 12, '8765432109876544', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 67120.95, '2021-12-16', CURRENT_TIMESTAMP()),
(13, 13, '7654321098765433', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 22980.25, '2020-01-11', CURRENT_TIMESTAMP()),
(14, 14, '6543210987654322', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 49850.60, '2021-02-06', CURRENT_TIMESTAMP()),
(15, 15, '5432109876543211', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 27240.85, '2020-03-03', CURRENT_TIMESTAMP()),
(16, 16, '4321098765432100', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 71430.20, '2021-03-29', CURRENT_TIMESTAMP()),
(17, 17, '3210987654321099', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 21560.45, '2020-04-24', CURRENT_TIMESTAMP()),
(18, 18, '2109876543210988', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 58720.80, '2021-05-19', CURRENT_TIMESTAMP()),
(19, 19, '1098765432109877', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 29580.15, '2020-06-14', CURRENT_TIMESTAMP()),
(20, 20, '0987654321098766', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 65240.50, '2021-07-09', CURRENT_TIMESTAMP()),
(21, 21, '9876543210987656', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 32100.90, '2020-08-04', CURRENT_TIMESTAMP()),
(22, 22, '8765432109876545', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 69350.25, '2021-08-29', CURRENT_TIMESTAMP()),
(23, 23, '7654321098765434', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 23870.60, '2020-09-24', CURRENT_TIMESTAMP()),
(24, 24, '6543210987654323', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 72840.75, '2021-10-19', CURRENT_TIMESTAMP()),
(25, 25, '5432109876543212', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 26250.30, '2020-11-14', CURRENT_TIMESTAMP()),
(26, 26, '4321098765432101', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 61780.95, '2021-12-09', CURRENT_TIMESTAMP()),
(27, 27, '3210987654321090', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 22430.40, '2020-01-04', CURRENT_TIMESTAMP()),
(28, 28, '2109876543210989', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 74920.10, '2021-01-29', CURRENT_TIMESTAMP()),
(29, 29, '1098765432109878', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 27890.55, '2020-02-23', CURRENT_TIMESTAMP()),
(30, 30, '0987654321098767', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 68450.85, '2021-03-20', CURRENT_TIMESTAMP()),
(31, 31, '9876543210987657', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 29640.20, '2020-04-15', CURRENT_TIMESTAMP()),
(32, 32, '8765432109876546', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 71280.45, '2021-05-10', CURRENT_TIMESTAMP()),
(33, 33, '7654321098765435', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 24260.70, '2020-06-05', CURRENT_TIMESTAMP()),
(34, 34, '6543210987654324', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 63790.95, '2021-06-30', CURRENT_TIMESTAMP()),
(35, 35, '5432109876543213', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 25780.25, '2020-07-25', CURRENT_TIMESTAMP()),
(36, 36, '4321098765432102', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 76120.50, '2021-08-20', CURRENT_TIMESTAMP()),
(37, 37, '3210987654321091', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 21950.80, '2020-09-15', CURRENT_TIMESTAMP()),
(38, 38, '2109876543210980', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 67640.15, '2021-10-10', CURRENT_TIMESTAMP()),
(39, 39, '1098765432109879', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 28320.40, '2020-11-05', CURRENT_TIMESTAMP()),
(40, 40, '0987654321098768', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 73580.65, '2021-11-30', CURRENT_TIMESTAMP()),
(41, 41, '9876543210987658', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 30560.90, '2020-12-25', CURRENT_TIMESTAMP()),
(42, 42, '8765432109876547', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 69120.35, '2022-01-19', CURRENT_TIMESTAMP()),
(43, 43, '7654321098765436', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 23470.60, '2021-02-14', CURRENT_TIMESTAMP()),
(44, 44, '6543210987654325', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 78840.80, '2022-03-11', CURRENT_TIMESTAMP()),
(45, 45, '5432109876543214', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 26930.15, '2021-04-06', CURRENT_TIMESTAMP()),
(46, 46, '4321098765432103', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 71950.40, '2022-05-01', CURRENT_TIMESTAMP()),
(47, 47, '3210987654321092', 'CHECKING', '026009593', 'Wells Fargo', 'ACTIVE', 24890.70, '2021-05-27', CURRENT_TIMESTAMP()),
(48, 48, '2109876543210981', 'SAVINGS', '124003116', 'Citibank', 'ACTIVE', 77280.95, '2022-06-21', CURRENT_TIMESTAMP()),
(49, 49, '1098765432109870', 'CHECKING', '021000021', 'Chase Bank', 'ACTIVE', 29140.20, '2021-07-16', CURRENT_TIMESTAMP()),
(50, 50, '0987654321098769', 'SAVINGS', '121042882', 'Bank of America', 'ACTIVE', 75320.55, '2022-08-11', CURRENT_TIMESTAMP());

-- Grant permissions on base tables
GRANT SELECT ON auto_classification.raw_data.customers_pii TO ROLE analyst;
GRANT SELECT ON auto_classification.raw_data.customers_pii TO ROLE limited_user;
GRANT SELECT ON auto_classification.raw_data.customers_pii TO ROLE data_steward;
GRANT SELECT ON auto_classification.raw_data.payment_cards_pci TO ROLE analyst;
GRANT SELECT ON auto_classification.raw_data.payment_cards_pci TO ROLE limited_user;
GRANT SELECT ON auto_classification.raw_data.payment_cards_pci TO ROLE data_steward;
GRANT SELECT ON auto_classification.raw_data.account_numbers_pan TO ROLE analyst;
GRANT SELECT ON auto_classification.raw_data.account_numbers_pan TO ROLE limited_user;
GRANT SELECT ON auto_classification.raw_data.account_numbers_pan TO ROLE data_steward;

-- ============================================================================
-- SECTION 2C: AUTOMATED DATA CLASSIFICATION SETUP
-- ============================================================================
-- Reference: https://medium.com/snowflake/data-classification-at-scale-using-snowflake-automated-sensitive-data-classification-0cb6b620484c

-- Step 2C.1: Grant Required Permissions for Automated Classification
USE ROLE ACCOUNTADMIN;

-- Grant classification admin permissions
GRANT APPLY TAG ON ACCOUNT TO ROLE governance_admin;
GRANT DATABASE ROLE SNOWFLAKE.CLASSIFICATION_ADMIN TO ROLE governance_admin;
GRANT EXECUTE AUTO CLASSIFICATION ON ACCOUNT TO ROLE governance_admin;

-- Step 2C.2: Create Classification Profile
USE ROLE governance_admin;
USE DATABASE governance_objects;
CREATE SCHEMA IF NOT EXISTS data_classification;

USE SCHEMA data_classification;

-- Create a classification profile with auto-tagging enabled
CREATE OR REPLACE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE standard_classification_profile(
    {
        'maximum_classification_validity_days': 180,
        'minimum_object_age_for_classification_days': 1,
        'auto_tag': true,
        'classify_views': true
    }
);

-- Step 2C.3: Attach Classification Profile to Auto Classification Schema
USE DATABASE auto_classification;
USE SCHEMA raw_data;

-- Attach the classification profile to the schema for automated classification
ALTER SCHEMA raw_data SET SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE = governance_objects.data_classification.standard_classification_profile;

-- Step 2C.4: Verify Classification Profile Attachment
SELECT 
    schema_name,
    classification_profile_name,
    classification_profile_status
FROM TABLE(INFORMATION_SCHEMA.CLASSIFICATION_PROFILES(
    schema_name => 'AUTO_CLASSIFICATION.RAW_DATA'
));

-- Note: Automated classification will run on the tables in this schema
-- The system will automatically discover and tag PII, PCI, and PAN data
-- Results will appear in the DATA_CLASSIFICATION_LATEST view after classification completes

-- ============================================================================
-- SECTION 3: MANUAL CLASSIFICATION - DISCOVERY & CLASSIFICATION
-- ============================================================================

-- Step 3.1: Enable Object Dependencies (Required for tag propagation)
ALTER ACCOUNT SET ENABLE_OBJECT_DEPENDENCIES = TRUE;

-- Step 3.2: Create Classification Tags for PII, PCI, PAN
USE DATABASE governance_objects;

CREATE TAG IF NOT EXISTS pii_sensitive;
CREATE TAG IF NOT EXISTS pci_sensitive;
CREATE TAG IF NOT EXISTS pan_sensitive;
CREATE TAG IF NOT EXISTS personal_data;
CREATE TAG IF NOT EXISTS financial_data;

-- Grant tag privileges
GRANT APPLY ON TAG pii_sensitive TO ROLE governance_admin;
GRANT APPLY ON TAG pci_sensitive TO ROLE governance_admin;
GRANT APPLY ON TAG pan_sensitive TO ROLE governance_admin;
GRANT APPLY ON TAG personal_data TO ROLE governance_admin;
GRANT APPLY ON TAG financial_data TO ROLE governance_admin;

-- Step 3.3: Manual Classification - Manually tag columns
USE ROLE governance_admin;
USE DATABASE manual_classification;
USE SCHEMA raw_data;

-- Manually tag columns in the manual classification database
ALTER TABLE customers_pii MODIFY COLUMN email SET TAG pii_sensitive = 'EMAIL_ADDRESS';
ALTER TABLE customers_pii MODIFY COLUMN social_security_number SET TAG pii_sensitive = 'SSN';
ALTER TABLE customers_pii MODIFY COLUMN phone SET TAG pii_sensitive = 'PHONE_NUMBER';
ALTER TABLE customers_pii MODIFY COLUMN date_of_birth SET TAG pii_sensitive = 'DATE_OF_BIRTH';
ALTER TABLE customers_pii MODIFY COLUMN first_name SET TAG personal_data = 'FIRST_NAME';
ALTER TABLE customers_pii MODIFY COLUMN last_name SET TAG personal_data = 'LAST_NAME';

ALTER TABLE payment_cards_pci MODIFY COLUMN card_number SET TAG pci_sensitive = 'CARD_NUMBER';
ALTER TABLE payment_cards_pci MODIFY COLUMN cvv SET TAG pci_sensitive = 'CVV';
ALTER TABLE payment_cards_pci MODIFY COLUMN expiration_date SET TAG pci_sensitive = 'EXPIRATION_DATE';
ALTER TABLE payment_cards_pci MODIFY COLUMN cardholder_name SET TAG personal_data = 'CARDHOLDER_NAME';

ALTER TABLE account_numbers_pan MODIFY COLUMN account_number SET TAG pan_sensitive = 'ACCOUNT_NUMBER';
ALTER TABLE account_numbers_pan MODIFY COLUMN routing_number SET TAG pan_sensitive = 'ROUTING_NUMBER';
ALTER TABLE account_numbers_pan MODIFY COLUMN balance SET TAG financial_data = 'ACCOUNT_BALANCE';

-- Verify tags applied
SELECT SYSTEM$GET_TAG('pii_sensitive', 'manual_classification.raw_data.customers_pii.email', 'COLUMN');
SELECT SYSTEM$GET_TAG('pci_sensitive', 'manual_classification.raw_data.payment_cards_pci.card_number', 'COLUMN');

-- ============================================================================
-- SECTION 4: CLASSIFY & GOVERN
-- ============================================================================

-- Step 4.1: Set up Data Quality Monitoring using Data Metric Functions

USE DATABASE governance_objects;
USE SCHEMA metrics;

-- Create custom data metric function for completeness
CREATE OR REPLACE FUNCTION completeness_metric(
    table_name STRING,
    column_name STRING
)
RETURNS FLOAT
AS
$$
    SELECT 
        COUNT(*) - COUNT(IDENTIFIER($column_name))::FLOAT / NULLIF(COUNT(*), 0) * 100.0
    FROM IDENTIFIER($table_name)
$$;

-- Create data quality metric for email completeness
CREATE OR REPLACE METRIC email_completeness
ON TABLE manual_classification.raw_data.customers_pii
AS (
    SELECT COUNT(*) - COUNT(email)::FLOAT / NULLIF(COUNT(*), 0) * 100.0
    FROM manual_classification.raw_data.customers_pii
);

-- Create data quality metric for unique values
CREATE OR REPLACE METRIC unique_customer_emails
ON TABLE manual_classification.raw_data.customers_pii
AS (
    SELECT COUNT(DISTINCT email)::FLOAT
    FROM manual_classification.raw_data.customers_pii
);

-- Query data quality metrics
SELECT * FROM TABLE(INFORMATION_SCHEMA.METRIC_FUNCTIONS());

-- Step 4.2: Manual Tagging and Tag Propagation

-- Create a transformed view that will inherit tags from manual_classification
USE DATABASE manual_classification;
CREATE SCHEMA IF NOT EXISTS transformed;
GRANT USAGE ON SCHEMA manual_classification.transformed TO ROLE governance_admin;
GRANT USAGE ON SCHEMA manual_classification.transformed TO ROLE data_steward;
GRANT USAGE ON SCHEMA manual_classification.transformed TO ROLE analyst;
GRANT USAGE ON SCHEMA manual_classification.transformed TO ROLE limited_user;

USE SCHEMA transformed;

CREATE OR REPLACE VIEW customer_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.city,
    c.state,
    COUNT(DISTINCT p.card_id) as card_count,
    COUNT(DISTINCT a.account_id) as account_count
FROM raw_data.customers_pii c
LEFT JOIN raw_data.payment_cards_pci p ON c.customer_id = p.customer_id
LEFT JOIN raw_data.account_numbers_pan a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.city, c.state;

-- Verify tag propagation to the view (tags propagate automatically to dependent objects)
SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_NAME,
    OBJECT_SCHEMA,
    OBJECT_DATABASE,
    OBJECT_DOMAIN
FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES(
    'manual_classification.transformed.customer_summary',
    'VIEW'
));

-- Step 4.3: Define a Contact associated with sensitive data domain

-- Create a contact for the data steward
USE DATABASE governance_objects;

CREATE CONTACT IF NOT EXISTS data_steward_contact
WITH 
    EMAIL = 'data.steward@company.com',
    FIRST_NAME = 'Data',
    LAST_NAME = 'Steward',
    PHONE = '555-0100';

-- Associate contact with sensitive data domain
-- Note: This is a conceptual representation; actual implementation may vary

-- ============================================================================
-- SECTION 5: OBFUSCATION & SECURE ACCESS
-- ============================================================================

-- Step 5.1: Row-Level Security - Row Access Policy (Aggregation/Projection Policy)

USE DATABASE governance_objects;
USE SCHEMA policies;

-- Create a mapping table for row access policy
CREATE OR REPLACE TABLE role_mapping (
    role_name VARCHAR,
    access_level VARCHAR
);

INSERT INTO role_mapping VALUES
('ANALYST', 'FULL'),
('LIMITED_USER', 'AGGREGATE_ONLY'),
('DATA_STEWARD', 'FULL'),
('GOVERNANCE_ADMIN', 'FULL');

-- Create Row Access Policy for aggregation-only access
CREATE OR REPLACE ROW ACCESS POLICY limited_user_aggregation_policy
AS (role_name VARCHAR) RETURNS BOOLEAN ->
    CASE 
        WHEN CURRENT_ROLE() = 'LIMITED_USER' THEN FALSE
        WHEN CURRENT_ROLE() IN ('ANALYST', 'DATA_STEWARD', 'GOVERNANCE_ADMIN') THEN TRUE
        ELSE FALSE
    END;

-- Apply Row Access Policy (Note: This example uses a simplified approach)
-- In practice, row access policies control which rows a user can see
-- For aggregation-only, we'll use Aggregation Policy instead

-- Step 5.2: Column Masking Policy (Dynamic Column Masking)

-- Create Column Masking Policy for email
CREATE OR REPLACE MASKING POLICY email_masking_policy AS 
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() = 'ANALYST' THEN val
        WHEN CURRENT_ROLE() = 'LIMITED_USER' THEN 
            LEFT(val, 3) || '***' || RIGHT(val, 4)
        ELSE '***MASKED***'
    END;

-- Apply masking policy to email column (on manual_classification tables)
USE ROLE ACCOUNTADMIN;
ALTER TABLE manual_classification.raw_data.customers_pii MODIFY COLUMN email 
SET MASKING POLICY governance_objects.policies.email_masking_policy;

-- Create Column Masking Policy for SSN
CREATE OR REPLACE MASKING POLICY ssn_masking_policy AS 
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() = 'ANALYST' THEN val
        WHEN CURRENT_ROLE() = 'DATA_STEWARD' THEN 'XXX-XX-' || RIGHT(val, 4)
        ELSE 'XXX-XX-XXXX'
    END;

ALTER TABLE manual_classification.raw_data.customers_pii MODIFY COLUMN social_security_number 
SET MASKING POLICY governance_objects.policies.ssn_masking_policy;

-- Step 5.3: Aggregation Policy

-- Create Aggregation Policy to enforce aggregation-only queries for LIMITED_USER
CREATE OR REPLACE AGGREGATION POLICY limited_user_aggregation
AS (aggregation_threshold INT) RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() = 'LIMITED_USER' THEN 
            aggregation_threshold >= 10
        ELSE TRUE
    END;

-- Apply aggregation policy to the tables (on manual_classification)
USE ROLE ACCOUNTADMIN;
ALTER TABLE manual_classification.raw_data.customers_pii 
SET AGGREGATION POLICY governance_objects.policies.limited_user_aggregation;

ALTER TABLE manual_classification.raw_data.payment_cards_pci 
SET AGGREGATION POLICY governance_objects.policies.limited_user_aggregation;

ALTER TABLE manual_classification.raw_data.account_numbers_pan 
SET AGGREGATION POLICY governance_objects.policies.limited_user_aggregation;

-- Step 5.4: Projection Policy

-- Create Projection Policy to limit which columns LIMITED_USER can access
CREATE OR REPLACE PROJECTION POLICY limited_user_projection
AS (projected_columns ARRAY) RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() = 'LIMITED_USER' THEN
            ARRAY_SIZE(projected_columns) <= 5
        ELSE TRUE
    END;

-- Apply projection policy to tables (on manual_classification)
ALTER TABLE manual_classification.raw_data.customers_pii 
SET PROJECTION POLICY governance_objects.policies.limited_user_projection;

ALTER TABLE manual_classification.raw_data.payment_cards_pci 
SET PROJECTION POLICY governance_objects.policies.limited_user_projection;

-- ============================================================================
-- SECTION 6: VERIFICATION & TESTING
-- ============================================================================

-- Step 6.1: Test as ANALYST role (should see unmasked data)
USE ROLE analyst;
USE WAREHOUSE demo_governance_wh;
USE DATABASE manual_classification;
USE SCHEMA raw_data;

-- Analyst should see full email addresses
SELECT customer_id, first_name, last_name, email, social_security_number 
FROM customers_pii 
LIMIT 5;

-- Step 6.2: Test as LIMITED_USER role (should see masked data and aggregation-only)
USE ROLE limited_user;

-- Limited user should see masked emails
SELECT customer_id, first_name, last_name, email, social_security_number 
FROM customers_pii 
LIMIT 5;

-- Limited user should only be able to run aggregation queries (threshold >= 10)
SELECT state, COUNT(*) as customer_count
FROM customers_pii
GROUP BY state;

-- Step 6.3: Verify tag propagation to secure view
USE ROLE analyst;

SELECT 
    customer_id,
    first_name,
    email,
    card_count,
    account_count
FROM transformed.customer_summary
LIMIT 10;

-- Check tags on the view
SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_NAME
FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES(
    'manual_classification.transformed.customer_summary',
    'VIEW'
));

-- Step 6.4: View all applied policies
USE ROLE governance_admin;

SELECT 
    POLICY_NAME,
    POLICY_TYPE,
    POLICY_STATUS
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    POLICY_NAME => 'limited_user_aggregation'
));

SELECT 
    POLICY_NAME,
    POLICY_TYPE,
    POLICY_STATUS
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    POLICY_NAME => 'email_masking_policy'
));

-- ============================================================================
-- SECTION 7: AUTOMATED CLASSIFICATION VERIFICATION
-- ============================================================================

-- Step 7.1: View Automated Classification Results
-- Note: Classification results will appear after the automated process completes
-- The classification profile is set with minimum_object_age_for_classification_days = 1
-- so results should appear within the classification validity period

USE ROLE governance_admin;
USE DATABASE auto_classification;

-- Query the DATA_CLASSIFICATION_LATEST view to see automated classification results
SELECT 
    object_database,
    object_schema,
    object_name,
    column_name,
    classification_type,
    probability,
    tag_name,
    tag_value
FROM TABLE(INFORMATION_SCHEMA.DATA_CLASSIFICATION_LATEST())
WHERE object_database = 'AUTO_CLASSIFICATION'
  AND object_schema = 'RAW_DATA'
ORDER BY object_name, column_name;

-- Step 7.2: View Tag Propagation in Auto Classification
-- Verify that automatically applied tags propagate to downstream objects

USE SCHEMA transformed;

CREATE OR REPLACE VIEW customer_summary_auto AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.city,
    c.state,
    COUNT(DISTINCT p.card_id) as card_count,
    COUNT(DISTINCT a.account_id) as account_count
FROM raw_data.customers_pii c
LEFT JOIN raw_data.payment_cards_pci p ON c.customer_id = p.customer_id
LEFT JOIN raw_data.account_numbers_pan a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.city, c.state;

-- Query tags on the view to see propagated tags from automated classification
SELECT 
    TAG_NAME,
    TAG_VALUE,
    OBJECT_NAME,
    OBJECT_SCHEMA,
    OBJECT_DATABASE,
    OBJECT_DOMAIN
FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES(
    'auto_classification.transformed.customer_summary_auto',
    'VIEW'
));

-- Step 7.3: Compare Manual vs Automated Classification
-- Query to compare classification approaches

SELECT 
    'MANUAL_CLASSIFICATION' as classification_method,
    object_name,
    column_name,
    tag_name,
    tag_value
FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'manual_classification.raw_data.customers_pii'
))
WHERE tag_name IS NOT NULL

UNION ALL

SELECT 
    'AUTOMATED_CLASSIFICATION' as classification_method,
    object_name,
    column_name,
    tag_name,
    tag_value
FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'auto_classification.raw_data.customers_pii'
))
WHERE tag_name IS NOT NULL
ORDER BY classification_method, object_name, column_name;

-- ============================================================================
-- CLEANUP (Optional - Comment out if you want to keep the demo objects)
-- ============================================================================

-- Uncomment the following to clean up demo objects:

/*
USE ROLE ACCOUNTADMIN;

DROP DATABASE IF EXISTS auto_classification;
DROP DATABASE IF EXISTS manual_classification;
DROP DATABASE IF EXISTS governance_objects;
DROP WAREHOUSE IF EXISTS demo_governance_wh;
DROP ROLE IF EXISTS data_steward;
DROP ROLE IF EXISTS analyst;
DROP ROLE IF EXISTS limited_user;
DROP ROLE IF EXISTS governance_admin;
*/

