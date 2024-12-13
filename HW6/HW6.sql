CREATE SCHEMA IF NOT EXISTS indexing;
use indexing;
-- when set, it prevents potentially dangerous updates and deletes
set SQL_SAFE_UPDATES=0;

-- when set, it disables the enforcement of foreign key constraints.
set FOREIGN_KEY_CHECKS=0;

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
-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$
CREATE PROCEDURE createTimeTable() -- created a procedure to make both tables (time and account)
BEGIN
 -- Create the time table
CREATE TABLE IF NOT EXISTS times (
TimeInMicroseconds INT
);

CREATE TABLE IF NOT EXISTS accounts (
  account_num CHAR(6) PRIMARY KEY,    -- 6-digit account number (e.g., 00001, 00002, ...)
  branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
  balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
  account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
);
END$$


CREATE PROCEDURE generate_accounts(IN amount INT) -- changed generate accounts to have an in variable to set the amount of items we wish for.
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);

CALL createTimeTable;
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
DECLARE execution_time_microseconds BIGINT; -- Initialize time hholding variable

CALL createTimeTable(); -- create the tables if they don't exist
CREATE INDEX idx_branch_name ON accounts(branch_name); -- create indexes now before we count time
CREATE INDEX idx_balance ON accounts(balance);

WHILE i <= 10 DO -- we do this to gather 10 times
	SET @start_time = NOW(6); -- starting timer

	SELECT count(*) FROM accounts FORCE INDEX (idx_branch_name, idx_balance) -- the main thing, selecting the items from the indexes
		WHERE branch_name = 'Downtown' AND balance = 50000; 
        
	SET @end_time = NOW(6); -- ending the timer
    
	SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time); -- we then save the time as a variable
    
	INSERT INTO times(TimeInMicroseconds) -- then we dump it into times table
	VALUES
	(
	execution_time_microseconds);
    
	SET i = i + 1;
	END WHILE;
    
SELECT TimeInMicroseconds FROM times; -- then we view the list at the end

DROP INDEX idx_branch_name ON accounts;
DROP INDEX idx_balance ON accounts;
DROP TABLE times;
END$$

CREATE PROCEDURE point2()
BEGIN
DECLARE i INT DEFAULT 1; -- Initialize the loop counter
DECLARE execution_time_microseconds BIGINT;

CALL createTimeTable();

WHILE i <= 10 DO
	SET @start_time = NOW(6);

	SELECT count(*) FROM accounts
		WHERE branch_name = 'Downtown' AND balance = 50000;
        
	SET @end_time = NOW(6);
    
	SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time);

	INSERT INTO times(TimeInMicroseconds)
	VALUES
	(
	execution_time_microseconds);
    
	SET i = i + 1;
	END WHILE;
    
SELECT TimeInMicroseconds FROM times;
DROP TABLE times;

END$$

CREATE PROCEDURE range1()
BEGIN
DECLARE i INT DEFAULT 1; -- Initialize the loop counter
DECLARE execution_time_microseconds BIGINT;

CREATE INDEX idx_branch_name ON accounts(branch_name);
CREATE INDEX idx_balance ON accounts(balance);

CALL createTimeTable();

WHILE i <= 10 DO
	SET @start_time = NOW(6);

	SELECT count(*) FROM accounts FORCE INDEX (idx_branch_name, idx_balance)
		WHERE branch_name = 'Downtown' AND balance BETWEEN 10000 AND 5000;
        
	SET @end_time = NOW(6);
    
	SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time);

	INSERT INTO times(TimeInMicroseconds)
	VALUES
	(
	execution_time_microseconds);
    
	SET i = i + 1;
	END WHILE;
    
SELECT TimeInMicroseconds FROM times
	ORDER BY TimeInMicroseconds DESC
	LIMIT 10;

DROP INDEX idx_branch_name ON accounts;
DROP INDEX idx_balance ON accounts;
END$$

CREATE PROCEDURE range2()
BEGIN
DECLARE i INT DEFAULT 1; -- Initialize the loop counter
DECLARE execution_time_microseconds BIGINT;

CALL createTimeTable();

WHILE i <= 10 DO
	SET @start_time = NOW(6);

	SELECT count(*) FROM accounts
		WHERE branch_name = 'Downtown' AND balance BETWEEN 10000 AND 5000;
        
	SET @end_time = NOW(6);
    
	SET execution_time_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time);

	INSERT INTO times(TimeInMicroseconds)
	VALUES
	(
	execution_time_microseconds);
    
	SET i = i + 1;
	END WHILE;
    
SELECT TimeInMicroseconds FROM times;

END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- ******************************************************************
-- execute the procedure
-- ******************************************************************
CALL generate_accounts(50000); -- Generate accou
CALL point1(); -- then continue by doing the calls (each call runs 10 times to get the 10 results
CALL point2(); -- each 1 call is w/indexes and each 2 call is w/out indexes
CALL range1(); -- at the end of each call, we get a list of 10 run times
Call range2(); -- this will be the data we use in our report
Drop table accounts; -- after we are done, we drop both tables to make way for the next run
Drop table times; -- then we restart all over again, generating 50k more accounts

CALL generate_accounts(100000);
CALL point1();
CALL point2();
CALL range1();
Call range2();
Drop table accounts;
Drop table times;

CALL generate_accounts(150000);
CALL point1();
CALL point2();
CALL range1();
Call range2();