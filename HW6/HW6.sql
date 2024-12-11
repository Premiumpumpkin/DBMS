Create Schema if not exists index50k;
Create Schema if not exists index100k;
Create Schema if not exists index150k;
/* **************************************************************************************** */
-- when set, it prevents potentially dangerous updates and deletes
set SQL_SAFE_UPDATES=0;

-- when set, it disables the enforcement of foreign key constraints.
set FOREIGN_KEY_CHECKS=0;

/* **************************************************************************************** 
-- These control:
--     the maximum time (in seconds) that the client will wait while trying to establish a 
	   connection to the MySQL server 
--     how long the client will wait for a response from the server once a request has 
       been sent over
**************************************************************************************** */
SHOW SESSION VARIABLES LIKE '%timeout%';       
SET GLOBAL mysqlx_connect_timeout = 600;
SET GLOBAL mysqlx_read_timeout = 600;


/* **************************************************************************************** */
-- The DB where the accounts table is created
CREATE SCHEMA IF NOT EXISTS indexing;
use indexing;



-- Create the accounts table
CREATE TABLE accounts (
  account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
  branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
  balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
  account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
);



/* ***************************************************************************************************
The procedure generates 50,000 records for the accounts table, with the account_num padded to 5 digits.
branch_name is randomly selected from one of the six predefined branches.
balance is generated randomly, between 0 and 100,000, rounded to two decimal places.
***************************************************************************************************** */
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE generate_accounts50000()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate 50,000 account records
  WHILE i <= 50000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE generate_accounts100000()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate 100,000 account records
  WHILE i <= 100000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER;

DELIMITER $$
CREATE PROCEDURE generate_accounts150000()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate 150,000 account records
  WHILE i <= 150000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;
-- ******************************************************************
-- execute the procedure
-- ******************************************************************
USE index50k;
CALL generate_accounts50000();
-- ******************************************************************************************
-- Timing analysis
-- ******************************************************************************************
-- Step 1: Capture the start time with microsecond precision (6)
SET @start_time = NOW(6);

SELECT count(*) FROM accounts  WHERE branch_name = 'Downtown' AND balance = 50000;
-- Step 2: Run the query you want to measure
SELECT count(*) FROM accounts 
WHERE branch_name = 'Downtown'
AND account_type = 'Savings';

-- Step 3: Capture the end time with microsecond precision
SET @end_time = NOW(6);

-- Step 4: Calculate the difference in microseconds
SELECT 
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS execution_time_seconds;


USE index100k;
CALL generate_accounts100000();
USE index150k;
CALL generate_accounts150000();

