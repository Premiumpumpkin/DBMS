CREATE SCHEMA IF NOT EXISTS indexing;
use indexing;
-- when set, it prevents potentially dangerous updates and deletes
set SQL_SAFE_UPDATES=0;

-- when set, it disables the enforcement of foreign key constraints.
set FOREIGN_KEY_CHECKS=0;
-- The DB where the accounts table is created
SHOW SESSION VARIABLES LIKE '%timeout%';       
SET GLOBAL mysqlx_connect_timeout = 1600;
SET GLOBAL mysqlx_read_timeout = 1600;

 -- Create the time table
CREATE TABLE IF NOT EXISTS times (
TimeInMicroseconds INT
);
  -- Create the accounts table
CREATE TABLE IF NOT EXISTS accounts (
  account_num CHAR(6) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
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

CREATE PROCEDURE generate_accounts(IN amount INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);

CREATE TABLE IF NOT EXISTS times (
TimeInMicroseconds INT
);

  -- Loop to generate #of amount account records
  WHILE i <= amount DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 6, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

CREATE PROCEDURE point1()
BEGIN
DECLARE i INT DEFAULT 1; -- Initialize the loop counter
DECLARE execution_time_microseconds BIGINT;

CREATE INDEX idx_branch_name ON accounts(branch_name);
CREATE INDEX idx_balance ON accounts(balance);

WHILE i <= 10 DO
	SET @start_time = NOW(6);

	SELECT count(*) FROM accounts FORCE INDEX (idx_branch_name, idx_balance)
		WHERE branch_name = 'Downtown' AND balance = 50000;
        
	SET @end_time = NOW(6);
	SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time);
    SELECT execution_time_microseconds;
	INSERT INTO times(TimeInMicroseconds)
	VALUES
	(
	execution_time_microseconds);
    
	SET i = i + 1;
	END WHILE;
    
SELECT TimeInMicroseconds From times;

DROP INDEX idx_branch_name ON accounts;
DROP INDEX idx_balance ON accounts;
END$$

CREATE PROCEDURE point2()
BEGIN
SET @start_time = NOW(6);

 SELECT count(*) FROM accounts  
    WHERE branch_name = 'Downtown' AND balance = 50000;
SET @end_time = NOW(6);

SELECT 
	TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;
END$$

CREATE PROCEDURE range1()
BEGIN
CREATE INDEX idx_branch_name ON accounts(branch_name);
CREATE INDEX idx_balance ON accounts(balance);

SET @start_time = NOW(6);

	SELECT count(*) FROM accounts FORCE INDEX (idx_branch_name, idx_balance)
		WHERE branch_name = 'Downtown' AND balance BETWEEN 10000 AND 5000;

SET @end_time = NOW(6);

#SELECT 
    #TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;
DROP INDEX idx_branch_name ON accounts;
DROP INDEX idx_balance ON accounts;
END$$

CREATE PROCEDURE range2()
BEGIN
SET @start_time = NOW(6);

 SELECT count(*) FROM accounts  
    WHERE branch_name = 'Downtown' AND balance = 50000;
SET @end_time = NOW(6);

SELECT 
	TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- ******************************************************************
-- execute the procedure
-- ******************************************************************
CALL generate_accounts(50000);
CALL point1();
CALL point2();
CALL range1();
Call range2();
Drop table accounts;
CALL generate_accounts(100000);
CALL point1();
CALL point2();
CALL range1();
Call range2();
Drop table accounts;
CALL generate_accounts(150000);
CALL point1();
CALL point2();
CALL range1();
Call range2();
#For the rest of these calls, I just manually added the 50k to the generate_accounts() method and restarted from there!
