-- Britney Sipkema
-- Database Structures - CISP 309
-- Final Project: 
-- 	Traffic Violations Master Script
-- May 2, 2026
-- =======================================================================
-- Traffic Violations and Ticket Management System
-- Phase II: Database Implementation
-- =======================================================================

-- The following script creates the database, tables, relationships, 
-- indexes, sample data, audit tables, triggers, functions, 
-- stored procedures, test scripts, and reports.

-- =======================================
-- SECTION 1: CREATE THE DATABASE
-- =======================================

-- Reset database so script can be re-run cleanly and without errors
DROP DATABASE IF EXISTS TrafficViolationsDB;

CREATE DATABASE TrafficViolationsDB;
USE TrafficViolationsDB;

-- ========================================
-- SECTION 2: CREATE LOOKUP TABLES
-- ** These tables come first because 
-- 	  other tables depend on them.
-- ========================================

-- This table stores valid vehicle type values
CREATE TABLE Ref_Vehicle_Types(
	vehicle_type_code        VARCHAR(10) PRIMARY KEY,
    vehicle_type_description VARCHAR(50) NOT NULL
);

-- This table stores valid ticket status values
CREATE TABLE Ref_Ticket_Status(
	ticket_status_code        VARCHAR(10) PRIMARY KEY,
    ticket_status_description VARCHAR(50) NOT NULL
);

-- ==========================================
-- SECTION 3: CREATE MAIN TABLES
-- ** The following tables are considered
-- 	  the 'parent' tables.
-- ==========================================

-- VIOLATORS TABLE:
-- This table stores people who receive violations

CREATE TABLE Violators(
	violator_id             INT AUTO_INCREMENT PRIMARY KEY,
    violator_first_name     VARCHAR(50) NOT NULL,
    violator_last_name      VARCHAR(50) NOT NULL,
    violator_phone          VARCHAR(20),
    violator_email          VARCHAR(100),
    violator_address        VARCHAR(150),
    date_of_first_violation DATE 
);

-- VEHICLES TABLE:
-- This table stores vehicles involved in violations

CREATE TABLE Vehicles(
	vehicle_license_number VARCHAR(20) PRIMARY KEY,
	vehicle_type_code      VARCHAR(10) NOT NULL,
    year_of_manufacture    YEAR,
    vehicle_make           VARCHAR(50) NOT NULL,
    vehicle_model          VARCHAR(50) NOT NULL,
    vehicle_color          VARCHAR(45),
    
    CONSTRAINT fk_vehicle_type_code
		FOREIGN KEY(vehicle_type_code)
        REFERENCES Ref_Vehicle_Types(vehicle_type_code)
);

-- OFFICERS TABLE:
-- This table stores officers who issue or record violations

CREATE TABLE Officers(
	officer_badge_number   VARCHAR(20) PRIMARY KEY,
    officer_first_name     VARCHAR(50) NOT NULL,
    officer_last_name      VARCHAR(50) NOT NULL,
    officer_rank           VARCHAR(50),
    officer_department     VARCHAR(75),
    officer_email          VARCHAR(100)
);

-- ========================================================
-- SECTION 4: CREATE RELATIONSHIP AND TRANSACTION TABLES
-- ========================================================

-- ** IMPORTANT: This bridge table connects violators and
--    vehicles.  The composite primary key prevents the same
--    violator/vehicle combination from being entered more than once.
-- --------------------------------------------------------------------------

-- VIOLATOR_VEHICLES TABLE:

CREATE TABLE Violator_Vehicles(
	violator_id             INT NOT NULL,
    vehicle_license_number  VARCHAR(20) NOT NULL,
    ownership_start_date    DATE,
    
    PRIMARY KEY(violator_id, vehicle_license_number),
    
    CONSTRAINT fk_vv_violator_id
		FOREIGN KEY(violator_id)
        REFERENCES Violators(violator_id),
        
	CONSTRAINT fk_vv_vehicle_license
		FOREIGN KEY(vehicle_license_number)
        REFERENCES Vehicles(vehicle_license_number)
);

-- VIOLATIONS TABLE:

-- The following table stores each violation event.
-- ** IMPORTANT: it connects the violator, vehicle,
--    and officer involved in the violation.
-- -------------------------------------------------------

CREATE TABLE Violations(
	violation_id              INT AUTO_INCREMENT PRIMARY KEY,
    violator_id               INT NOT NULL,
    vehicle_license_number    VARCHAR(20) NOT NULL,
    officer_badge_number      VARCHAR(20) NOT NULL,
    violation_datetime        DATETIME NOT NULL,
    violation_location        VARCHAR(150) NOT NULL,
    violation_type            VARCHAR(75) NOT NULL,
    violation_description     VARCHAR(255),
    
    CONSTRAINT fk_violations_violator
		FOREIGN KEY (violator_id)
		REFERENCES Violators(violator_id),
    
    CONSTRAINT fk_violations_vehicle
		FOREIGN KEY (vehicle_license_number)
        REFERENCES Vehicles(vehicle_license_number),
        
	CONSTRAINT fk_violations_officer
		FOREIGN KEY (officer_badge_number)
        REFERENCES Officers(officer_badge_number)
);

-- This table stores the tickets issued for violations

CREATE TABLE Tickets(
	ticket_number             INT AUTO_INCREMENT PRIMARY KEY,
    violation_id              INT NOT NULL,
    ticket_status_code        VARCHAR(10) NOT NULL,
    ticket_issue_date         DATE NOT NULL,
    ticket_due_date           DATE NOT NULL,
    ticket_paid_date          DATE,
    ticket_amount             DECIMAL(8,2) NOT NULL,
    ticket_notes              VARCHAR(255),
    
    CONSTRAINT fk_tickets_violation
		FOREIGN KEY (violation_id)
        REFERENCES Violations(violation_id),
        
	CONSTRAINT fk_ticket_status
		FOREIGN KEY (ticket_status_code)
        REFERENCES Ref_Ticket_Status(ticket_status_code)
);

-- SHOW TABLES;

-- ================================================================
-- SECTION 5: INSERT LOOKUP DATA
-- ================================================================

-- Vehicle type lookup values:
-- ** IMPORTANT: these records must be inserted before Vehicles
--    because Vehicles uses vehicle_type_code as a foreign key.
-- --------------------------------------------------------------

INSERT INTO Ref_Vehicle_Types
	(vehicle_type_code, vehicle_type_description)
VALUES
	('SEDAN', 'Sedan'),
    ('SUV', 'Sport Utility Vehicle'),
    ('TRUCK', 'Pickup Truck'),
    ('VAN', 'Van'),
    ('MOTOR', 'Motorcycle'),
    ('BUS', 'Bus'),
    ('COUPE','Coupe'),
    ('CONV', 'Convertible'),
    ('WAGON', 'Station Wagon'),
    ('SEMI', 'Semi Truck'),
    ('TRAILER', 'Trailer'),
    ('TAXI', 'Taxi'),
    ('EV', 'Electric Vehicle'),
    ('HYBRID', 'Hybrid Vehicle'),
    ('OTHER', 'Other Vehcile Types');
 
 
-- Ticket Status lookup values
-- ** IMPORTANT: this is a support table so it has less than 15 rows 
--    because only a limited number of status categories are needed.
-- -------------------------------------------------------------------

INSERT INTO Ref_Ticket_Status
	(ticket_status_code, ticket_status_description)
VALUES
	('ISSUED', 'Ticket has been issued but not yet paid'),
    ('PAID', 'Ticket has been paid'),
    ('OVERDUE', 'Ticket payment is past the due date'),
    ('CANCELLED', 'Ticket has been cancelled'),
    ('APPEAL', 'Ticket is under appeal'),
    ('DISMISSED', 'Ticket has been dismissed'),
    ('VOID', 'Ticket was entered in error and voided');
    
SELECT * FROM Ref_Vehicle_Types;
SELECT * FROM Ref_Ticket_Status;

-- ==========================================================
-- SECTION 6: INSERT VIOLATORS DATA
-- ==========================================================

INSERT INTO Violators
	(violator_first_name, 
     violator_last_name, 
     violator_phone, 
     violator_email, 
     violator_address, 
     date_of_first_violation)

VALUES
	('John',       'Smith',     '616-555-1001',   'john.smith@finalproject.com',         '123 Maple St, Grand Rapids, MI',   '2023-01-15'),
    ('Emily',      'Johnson',   '616-555-1002',   'emily.johnson@finalproject.com',      '456 Oak Ave, Grand Rapids, MI',    '2023-02-10'),
    ('Michael',    'Williams',  '616-555-1003',   'michael.williams@finalproject.com',   '789 Pine Rd, Wyoming, MI',         '2023-03-05'),
    ('Sarah',      'Brown',     '616-555-1004',   'sarah.brown@finalproject.com',        '321 Birch St, Kentwood, MI',       '2023-01-25'),
    ('David',      'Jones',     '616-555-1005',   'david.jones@finalproject.com',        '654 Cedar Ln, Grandville, MI',     '2023-04-12'),
    ('Jessica',    'Garcia',    '616-555-1006',   'jessica.garcia@finalproject.com',     '987 Elm St, Walker, MI',           '2024-02-18'),
    ('Daniel',     'Martinez',  '616-555-1007',   'daniel.martinez@finalproject.com',    '159 Spruce Dr, Holland, MI',       '2025-05-01'),
    ('Ashley',     'Rodriguez', '616-555-1008',   'ashley.rodriguez@finalproject.com',   '753 Willow Ct, Zeeland, MI',       '2025-03-22'),
    ('Matthew',    'Davis',     '616-555-1009',   'matthew.davis@finalproject.com',      '852 Aspen Way, Byron Center, MI',  '2023-01-30'),
    ('Amanda',     'Lopez',     '616-555-1010',   'amanda.lopez@finalproject.com',       '951 Cherry St, Grand Rapids, MI',  '2025-04-08'),
    ('Joshua',     'Gonzalez',  '616-555-1011',   'joshua.gonzalez@finalproject.com',    '147 Walnut St, Wyoming, MI',       '2026-02-27'),
    ('Stephanie',  'Wilson',    '616-555-1012',   'stephanie.wilson@finalproject.com',   '258 Poplar Ave, Kentwood, MI',     '2024-03-14'),
    ('Andrew',     'Anderson',  '616-555-1013',   'andrew.anderson@finalproject.com',    '369 Hickory Rd, Grandville, MI',   '2023-05-10'),
    ('Nicole',     'Thomas',    '616-555-1014',   'nicole.thomas@finalproject.com',      '741 Redwood Dr, Walker, MI',       '2025-04-20'),
    ('Ryan',       'Taylor',    '616-555-1015',   'ryan.taylor@finalproject.com',        '852 Magnolia Ln, Holland, MI',     '2025-11-23');


-- ============================================
-- SECTION 7: INSERT OFFICERS DATA
-- ============================================

INSERT INTO Officers
	(officer_badge_number,
     officer_first_name,
     officer_last_name,
     officer_rank,
     officer_department,
     officer_email)
     
VALUES
	('B1001',   'James',         'Anderson',   'Officer',      'Traffic Division',   'james.anderson@finalproject.com'),
    ('B1002',   'Maria',         'Lopez',      'Sergeant',     'Traffic Division',   'maria.lopez@finalproject.com'),
    ('B1003',   'Robert',        'Taylor',     'Officer',      'Patrol',             'robert.taylor@finalproject.com'),
    ('B1004',   'Linda',         'Harris',     'Lieutenant',   'Traffic Division',   'linda.harris@finalproject.com'),
    ('B1005',   'William',       'Clark',      'Officer',      'Patrol',             'william.clark@finalproject.com'),
    ('B1006',   'Patricia',      'Lewis',      'Sergeant',     'Patrol',             'patricia.lewis@finalproject.com'),
    ('B1007',   'Charles',       'Walker',     'Officer',      'Traffic Division',   'charles.walker@finalproject.com'),
    ('B1008',   'Barbara',       'Hall',       'Officer',      'Traffic Division',   'barbara.hall@finalproject.com'),
    ('B1009',   'Thomas',        'Allen',      'Captain',      'Traffic Division',   'thomas.allen@finalproject.com'),
    ('B1010',   'Jennifer',      'Young',      'Officer',      'Patrol',             'jennifer.young@finalproject.com'),
    ('B1011',   'Christopher',   'King  ',     'Officer',      'Traffic Division',   'christopher.king@finalproject.com'),
    ('B1012',   'Susan',         'Wright',     'Sergeant',     'Traffic Division',   'susan.wright@finalproject.com'),
    ('B1013',   'Daniel',        'Scott',      'Officer',      'Patrol',             'daniel.scott@finalproject.com'),
    ('B1014',   'Karen',         'Green',      'Lieutenant',   'Traffic Division',   'karen.green@finalproject.com'),
    ('B1015',   'Matthew',       'Baker',      'Officer',      'Patrol',             'matthew.baker@finalproject.com');


-- ==================================================== 
-- SECTION 8: INSERT VEHICLES DATA
-- ====================================================

INSERT INTO Vehicles
	(vehicle_license_number,
     vehicle_type_code,
     year_of_manufacture,
     vehicle_make,
     vehicle_model,
     vehicle_color)
     
VALUES
	('ABC1234', 'SEDAN',     2018,   'Toyota',        'Camry',          'Black'),
    ('XYZ5678', 'SUV',       2020,   'Honda',         'CR-V',           'White'),
    ('LMN8910', 'TRUCK',     2017,   'Ford',          'F-150',          'Blue'),
    ('QRS2345', 'VAN',       2019,   'Dodge',         'Caravan',        'Silver'),
    ('TUV6789', 'MOTOR',     2021,   'Yamaha',        'MT-07',          'Red'),
    ('JKL3456', 'COUPE',     2024,   'BMW',           'M4',             'Black'),
    ('DEF7890', 'CONV',      2025,   'Chevrolet',     'Camaro',         'Yellow'),
    ('GHI1122', 'WAGON',     2018,   'Subaru',        'Outback',        'Green'),
    ('JKM3344', 'SEMI',      2014,   'Freightliner',  'Cascadia',       'White'),
    ('NOP5566', 'TRAILER',   2013,   'Utility',       'Trailer',        'Gray'),
    ('RST7788', 'TAXI',      2019,   'Toyota',        'Prius',          'Yellow'),
    ('UVW9900', 'EV',        2022,   'Tesla',         'Model 3',        'White'),
    ('AAA1111', 'HYBRID',    2023,   'Toyota',        'Corolla Hybrid', 'Blue'),
    ('BBB2222', 'SUV',       2020,   'Jeep',          'Grand Cherokee', 'Black'),
    ('CCC3333', 'SEDAN',     2017,   'Nissan',        'Altima',         'Silver');

-- =========================================================
-- SECTION 9: INSERT VIOLATOR_VEHICLES DATA
-- =========================================================

INSERT INTO Violator_Vehicles
	(violator_id,
     vehicle_license_number,
     ownership_start_date)

VALUES
	(1,  'ABC1234', '2022-01-10'),
    (2,  'XYZ5678', '2021-06-15'),
    (3,  'LMN8910', '2020-03-20'),
    (4,  'QRS2345', '2022-11-05'),
    (5,  'TUV6789', '2023-02-18'),
    (6,  'JKL3456', '2019-07-22'),
    (7,  'DEF7890', '2018-09-30'),
    (8,  'GHI1122', '2021-12-01'),
    (9,  'JKM3344', '2017-04-17'),
    (10, 'NOP5566', '2016-08-09'),
    (11, 'RST7788', '2020-10-14'),
    (12, 'UVW9900', '2023-01-25'),
    (13, 'AAA1111', '2022-06-06'),
    (14, 'BBB2222', '2021-03-11'),
    (15, 'CCC3333', '2019-05-27');


-- ==========================================
-- SECTION 10: INSERT VIOLATIONS DATA
-- ==========================================

INSERT INTO Violations
	(violator_id,
	 vehicle_license_number,
	 officer_badge_number,
	 violation_datetime,
	 violation_location,
	 violation_type,
	 violation_description)
     
VALUES
	(1,  'ABC1234', 'B1001', '2023-06-01 08:30:00', 'Grand Rapids, MI',   'Speeding',         'Exceeded speed limit by 15 mph'),
    (2,  'XYZ5678', 'B1002', '2023-06-02 09:45:00', 'Wyoming, MI',        'Red Light',        'Failed to stop at red light'),
    (3,  'LMN8910', 'B1003', '2023-06-03 11:15:00', 'Kentwood, MI',       'Illegal Turn',     'Made an illegal left turn'),
    (4,  'QRS2345', 'B1004', '2023-06-04 14:20:00', 'Grandville, MI',     'Speeding',         'Exceeded speed limit by 10 mph'),
    (5,  'TUV6789', 'B1005', '2023-06-05 16:05:00', 'Walker, MI',         'No Helmet',        'Motorcycle rider without helmet'),
    (6,  'JKL3456', 'B1006', '2023-06-06 10:10:00', 'Holland, MI',        'Expired Plates',   'Vehicle registration expired'),
    (7,  'DEF7890', 'B1007', '2023-06-07 13:55:00', 'Zeeland, MI',        'Speeding',         'Exceeded speed limit by 20 mph'),
    (8,  'GHI1122', 'B1008', '2023-06-08 07:40:00', 'Byron Center, MI',   'Seatbelt',         'Driver not wearing seatbelt'), 
    (9,  'JKM3344', 'B1009', '2023-06-09 18:25:00', 'Grand Rapids, MI',   'Overweight Load',  'Truck exceeded weight limit'),
    (10, 'NOP5566', 'B1010', '2023-06-10 12:00:00', 'Wyoming, MI',        'Improper Load',    'Trailer load not secured properly'),
    (11, 'RST7788', 'B1011', '2023-06-11 15:35:00', 'Kentwood, MI',       'Reckless Driving', 'Aggressive lane changes observed'),
    (12, 'UVW9900', 'B1012', '2023-06-12 09:10:00', 'Grandville, MI',     'Speeding',         'Exceeded speed limit by 12 mph'),
    (13, 'AAA1111', 'B1013', '2023-06-13 11:50:00', 'Walker, MI',         'Distracted',       'Using phone while driving'),
    (14, 'BBB2222', 'B1014', '2023-06-14 13:30:00', 'Holland, MI',        'Tailgating',       'Following too closely'),
    (15, 'CCC3333', 'B1015', '2023-06-15 17:45:00', 'Zeeland, MI',        'Speeding',         'Exceeded speed limit by 18 mph'); 
         
-- ===================================================
-- SECTION 11: INSERT TICKETS DATA
-- ===================================================

INSERT INTO Tickets
	(violation_id,
     ticket_status_code,
     ticket_issue_date,
     ticket_due_date,
     ticket_paid_date,
     ticket_amount,
     ticket_notes)

VALUES
	(1,  'PAID',       '2023-06-01',  '2023-07-01',  '2023-06-20',   125.00,   'Paid before due date'),
    (2,  'ISSUED',     '2023-06-02',  '2023-07-02',  NULL,           150.00,   'Awaiting payment'),
    (3,  'PAID',       '2023-06-03',  '2023-07-03',  '2023-06-25',   100.00,   'Paid online'),
    (4,  'OVERDUE',    '2023-06-04',  '2023-07-04',  NULL,           125.00,   'Payment past due'),
    (5,  'ISSUED',     '2023-06-05',  '2023-07-05',  NULL,           75.00,    'Initial ticket issued'),
    (6,  'PAID',       '2023-06-06',  '2023-07-06',  '2023-06-30',   90.00,    'Paid at clerk office'),
    (7,  'APPEAL',     '2023-06-07',  '2023-07-07',  NULL,           175.00,   'Ticket under appeal'),
    (8,  'PAID',       '2023-06-08',  '2023-07-08',  '2023-06-28',   65.00,    'Paid before due date'),
    (9,  'OVERDUE',    '2023-06-09',  '2023-07-09',  NULL,           250.00,   'Commercial vehicle fine overdue'),
    (10, 'ISSUED',     '2023-06-10',  '2023-07-10',  NULL,           200.00,   'Load violation ticket issued'),
    (11, 'CANCELLED',  '2023-06-11',  '2023-07-11',  NULL,           300.00,   'Cancelled after review'),
    (12, 'PAID',       '2023-06-12',  '2023-07-12',  '2023-07-01',   125.00,   'Paid online'),
    (13, 'ISSUED',     '2023-06-13',  '2023-07-13',  NULL,           110.00,   'Distracted driving citation'),
    (14, 'DISMISSED',  '2023-06-14',  '2023-07-14',  NULL,           100.00,   'Dismissed by court'),
    (15, 'VOID',       '2023-06-15',  '2023-07-15',  NULL,           125.00,   'Voided due to entry error');

-- =========================================
-- SECTION 12: CREATE INDEXES	
-- ** Indexes improve search and join
--    performance on commonly used fields.
-- =========================================

CREATE INDEX idx_violators_last_name
ON Violators (violator_last_name);

CREATE INDEX idx_vehicles_type
ON Vehicles (vehicle_type_code);

CREATE INDEX idx_violations_datetime
ON Violations (violation_datetime);

CREATE INDEX idx_violations_type
ON Violations (violation_type);

CREATE INDEX idx_tickets_status
ON Tickets (ticket_status_code);

CREATE INDEX idx_tickets_due_date
ON Tickets (ticket_due_date);

SHOW INDEX FROM Violations;
SHOW INDEX FROM Tickets;

-- ==========================================
-- SECTION 13: CREATE AUDIT TABLES
-- ==========================================

-- This audit table tracks changes made to ticket records

CREATE TABLE Ticket_Audit(
	audit_id           INT  AUTO_INCREMENT  PRIMARY KEY,
    ticket_number      INT,
    old_status_code    VARCHAR(10),
    new_status_code    VARCHAR(10),
    old_ticket_amount  DECIMAL(8,2),
    new_ticket_amount  DECIMAL(8,2),
    action_type        VARCHAR(20),
    changed_at         TIMESTAMP  DEFAULT  CURRENT_TIMESTAMP
);

-- This audit table tracks changes made to violation records.

CREATE TABLE Violation_Audit(
	audit_id                INT  AUTO_INCREMENT  PRIMARY KEY,
    violation_id            INT,
    old_violation_type      VARCHAR(75),
    new_violation_type      VARCHAR(75),
    old_violation_location  VARCHAR(150),
    new_violation_location  VARCHAR(150),
    action_type             VARCHAR(20),
    changed_at              TIMESTAMP  DEFAULT  CURRENT_TIMESTAMP
);


-- ============================================
-- SECTION 14: TRIGGER FOR TICKETS (UPDATE)
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_ticket_update
AFTER UPDATE ON Tickets
FOR EACH ROW
BEGIN
	INSERT INTO Ticket_Audit
    (
		ticket_number,
        old_status_code,
        new_status_code,
        old_ticket_amount,
        new_ticket_amount,
        action_type
	)
    VALUES
    (
		OLD.ticket_number,
        OLD.ticket_status_code,
        NEW.ticket_status_code,
        OLD.ticket_amount,
        NEW.ticket_amount,
        'UPDATE'
	);
END$$

DELIMITER ;

-- =============================================
-- SECTION 15: TRIGGER FOR VIOLATIONS (UPDATE)
-- =============================================

DELIMITER $$

CREATE TRIGGER trg_violation_update
AFTER UPDATE ON Violations
FOR EACH ROW
BEGIN
	INSERT INTO Violation_Audit
    (
		violation_id,
        old_violation_type,
        new_violation_type,
        old_violation_location,
        new_violation_location,
        action_type
	)
    VALUES
    (
		OLD.violation_id,
        OLD.violation_type,
        NEW.violation_type,
        OLD.violation_location,
        NEW.violation_location,
        'UPDATE'
	);
END$$

DELIMITER ;

-- Update a ticket
UPDATE Tickets
SET ticket_amount = 200.00
WHERE ticket_number = 1;

-- Check audit table
SELECT * FROM Ticket_Audit;


-- Update a violation
UPDATE Violations
SET violation_type = 'Reckless Driving'
WHERE violation_id = 1;

-- Check audit table
SELECT * FROM Violation_Audit;

-- ==================================================
-- SECTION 16: CREATE VALIDATION FUNCTIONS
-- ==================================================

-- This function checks whether a violator exists
-- it returns 1 if the violator exists and 0 if not.
-- --------------------------------------------------

DELIMITER $$

CREATE FUNCTION fn_violator_exists(p_violator_id INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
	DECLARE v_count INT;
    
    SELECT COUNT(*)
    INTO v_count
    FROM Violators
    WHERE violator_id = p_violator_id;
    
    RETURN v_count > 0;
END$$

DELIMITER ;

-- This function checks whether a ticket status code exists
-- it returns 1 if the status exists and 0 if not.
-- ---------------------------------------------------------

DELIMITER $$

CREATE FUNCTION fn_ticket_status_exists(p_ticket_status_code VARCHAR(10))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
	DECLARE v_count INT;
    
    SELECT COUNT(*)
    INTO v_count
    FROM Ref_Ticket_Status
    WHERE ticket_status_code = p_ticket_status_code;
    
    RETURN v_count > 0;
END$$

DELIMITER ;

-- ==================================================
-- SECTION 17: TEST VALIDATION FUNCTIONS
-- ==================================================

-- Should return 1 because violator_id 1 exists.
SELECT fn_violator_exists(1) AS violator_exists_test;

-- Should return 0 because violator_id 999 does not exist.
SELECT fn_violator_exists(999) AS violator_missing_test;

-- Should return 1 because PAID exists in Ref_Ticket_Status.
SELECT fn_ticket_status_exists('PAID') AS status_exists_test;

-- Should return 0 because FAKE is not a valid status.
SELECT fn_ticket_status_exists('FAKE') AS status_missing_test;



-- ====================================================
-- SECTION 18: STORED PROCEDURE - INSERT TICKET
-- ====================================================

-- The stored procedure automates inserting ticket data while
-- checking that the ticket status is valid.  It prevents bad
-- data from being added and ensures consistency in the database.
-- ---------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_insert_ticket (
    IN p_violation_id INT,
    IN p_ticket_status_code VARCHAR(10),
    IN p_ticket_issue_date DATE,
    IN p_ticket_due_date DATE,
    IN p_ticket_paid_date DATE,
    IN p_ticket_amount DECIMAL(8,2),
    IN p_ticket_notes VARCHAR(255)
)
BEGIN

    -- Validate ticket status
    IF fn_ticket_status_exists(p_ticket_status_code) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid ticket status code';
    END IF;

    -- Insert if valid
    INSERT INTO Tickets
    (
        violation_id,
        ticket_status_code,
        ticket_issue_date,
        ticket_due_date,
        ticket_paid_date,
        ticket_amount,
        ticket_notes
    )
    VALUES
    (
        p_violation_id,
        p_ticket_status_code,
        p_ticket_issue_date,
        p_ticket_due_date,
        p_ticket_paid_date,
        p_ticket_amount,
        p_ticket_notes
    );

END$$

DELIMITER ;

-- Valid insert
CALL sp_insert_ticket(
    1,
    'PAID',
    '2023-07-01',
    '2023-08-01',
    '2023-07-15',
    120.00,
    'Inserted via procedure'
);


-- Invalid test (should ERROR)
CALL sp_insert_ticket(
    1,
    'FAKE',
    '2023-07-01',
    '2023-08-01',
    NULL,
    120.00,
    'This should fail'
);

-- ====================================================
-- SECTION 19: STORED PROCEDURE - UPDATE TICKET STATUS
-- ====================================================

-- This procedure updates a ticket's status, but first
-- checks that the new status is valid
-- -----------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_update_ticket_status (
    IN p_ticket_number INT,
    IN p_new_ticket_status_code VARCHAR(10),
    IN p_ticket_paid_date DATE
)
BEGIN

    -- Validate ticket status before updating the ticket.
    IF fn_ticket_status_exists(p_new_ticket_status_code) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid ticket status code';
    END IF;

    -- Update the ticket if the status code is valid.
    UPDATE Tickets
    SET 
        ticket_status_code = p_new_ticket_status_code,
        ticket_paid_date = p_ticket_paid_date
    WHERE ticket_number = p_ticket_number;

END$$

DELIMITER ;


-- Valid update
CALL sp_update_ticket_status(2, 'PAID', '2023-07-01');

-- Check result
SELECT * FROM Tickets WHERE ticket_number = 2;

-- Invalid update test: this should fail
CALL sp_update_ticket_status(3, 'FAKE', NULL);



-- =====================================================
-- SECTION 20: STORED PROCEDURE - INSERT VIOLATION
-- =====================================================

-- This stored procedure inswerts a violation record while validating
-- that the violator exists in the system.  If the violator ID is invalid,
-- the procedure stops execution and returns an error.  This ensures
-- that all violations are linked to valid invididuals and maintains
-- referential integrity.
-- -------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_insert_violation (
    IN p_violator_id INT,
    IN p_vehicle_license_number VARCHAR(20),
    IN p_officer_badge_number VARCHAR(20),
    IN p_violation_datetime DATETIME,
    IN p_violation_location VARCHAR(150),
    IN p_violation_type VARCHAR(75),
    IN p_violation_description VARCHAR(255)
)
BEGIN

    -- Validate violator exists
    IF fn_violator_exists(p_violator_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid violator ID';
    END IF;

    -- Insert if valid
    INSERT INTO Violations
    (
        violator_id,
        vehicle_license_number,
        officer_badge_number,
        violation_datetime,
        violation_location,
        violation_type,
        violation_description
    )
    VALUES
    (
        p_violator_id,
        p_vehicle_license_number,
        p_officer_badge_number,
        p_violation_datetime,
        p_violation_location,
        p_violation_type,
        p_violation_description
    );

END$$

DELIMITER ;


-- Valid insert
CALL sp_insert_violation(
    1,
    'ABC1234',
    'B1001',
    '2023-07-20 10:00:00',
    'Grand Rapids, MI',
    'Speeding',
    'Inserted via procedure'
);

-- Invalid test (should ERROR)
CALL sp_insert_violation(
    999,
    'ABC1234',
    'B1001',
    '2023-07-20 10:00:00',
    'Grand Rapids, MI',
    'Speeding',
    'This should fail'
);

-- =====================================================
-- SECTION 21A: DETAILED REPORT
-- =====================================================

SELECT
    Tickets.ticket_number,
    Violators.violator_first_name,
    Violators.violator_last_name,
    Vehicles.vehicle_license_number,
    Vehicles.vehicle_make,
    Vehicles.vehicle_model,
    Violations.violation_type,
    Violations.violation_location,
    Officers.officer_badge_number,
    Tickets.ticket_amount,
    Tickets.ticket_status_code
FROM Tickets
JOIN Violations
    ON Tickets.violation_id = Violations.violation_id
JOIN Violators
    ON Violations.violator_id = Violators.violator_id
JOIN Vehicles
    ON Violations.vehicle_license_number = Vehicles.vehicle_license_number
JOIN Officers
    ON Violations.officer_badge_number = Officers.officer_badge_number;


-- =====================================================
-- SECTION 21B: SUMMARY REPORT
-- =====================================================

SELECT
    ticket_status_code,
    COUNT(*) AS total_tickets,
    SUM(ticket_amount) AS total_amount
FROM Tickets
GROUP BY ticket_status_code;





    











