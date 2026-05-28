/*
==============================================================================
CREATE CLEAN SALES TABLE & VALIDATION TESTS
==============================================================================
Purpose:
    - Build a cleaned transactional dataset for analytical processing
    - Standardize data types and remove invalid records
    - Classify transaction categories for business transparency
    - Preserve only valid customer purchasing activity
    - Validate data integrity before RFM segmentation

Queries: 
	1. TABLE CREATION AND DATA INSERTION
	- -	1.1. Create Table clean_sales
	- -	1.2. Load Cleaned Data
	2. VALIDATION TESTS
	- - 2.1. Table Inspection
	- - 2.2. NULL			   Validation
	- - 2.3. Negative Values   Validation
	- - 2.4. Cancellation & Accounting Adjustments Validation
	- - 2.5. Duplicates        Validation
	- - 2.6. InvoiceDate Range Validation
	- - 2.7. Price             Validation
	- - 2.8. Transaction_Type  Validation 
------------------------------------------------------------------------------
*/
USE rfm
GO

/*
==============================================================================
 1. TABLE CREATION AND DATA INSERTION
==============================================================================

---------------------------------------------
-- 1.1. Create Table clean_sales
---------------------------------------------
*/
DROP TABLE IF EXISTS clean_sales;
GO

CREATE TABLE clean_sales (
	Invoice			 VARCHAR(50),
	StockCode		 VARCHAR(50),
	[Description]	 VARCHAR(255),
	Quantity		 INT,
	InvoiceDate		 DATETIME2,
	Price			 DECIMAL(10,2),
	Customer_ID		 INT,
	Country			 VARCHAR(50),
	Revenue          AS (Quantity * Price),
	Transaction_Type VARCHAR(50)
);


---------------------------------------------
-- 1.2. Load Cleaned Data
---------------------------------------------
INSERT INTO clean_sales (
	Invoice,
	StockCode,
	[Description],
	Quantity,
	InvoiceDate,
	Price,
	Customer_ID,
	Country,
	Transaction_Type
)
SELECT DISTINCT
	Invoice,
	StockCode,
	[Description],
	CAST(Quantity AS int) AS Quantity,
	CAST(InvoiceDate AS datetime2) AS InvoiceDate,
	CAST(Price AS decimal(10,2)) AS Price,
	CAST(Customer_ID AS int) AS Customer_ID,
	Country,
	CASE 
		WHEN UPPER(StockCode) IN ('ADJUST', 'ADJUST2', 'B', 'BANK CHARGES', 'M') THEN 'ADJUSTMENT'
		WHEN UPPER(StockCode) IN ('POST', 'DOT', 'C2') THEN 'POSTAGE'
		WHEN UPPER(StockCode) = 'D' THEN 'DISCOUNT'
		WHEN UPPER(StockCode) = 'S' THEN 'SAMPLE'
		WHEN UPPER(StockCode) LIKE 'GIFT%' THEN 'GIFT VOUCHER'
		WHEN UPPER(StockCode) IN ('TEST001', 'TEST002') THEN 'TEST'
		ELSE 'PRODUCT'
	END AS Transaction_Type
FROM online_retail_II
WHERE 
	Invoice       IS NOT NULL
AND LEN(Invoice)  = 6
AND StockCode     IS NOT NULL
AND [Description] IS NOT NULL
AND Quantity      IS NOT NULL
AND CAST(Quantity AS int) > 0
AND InvoiceDate   IS NOT NULL
AND Price         IS NOT NULL
AND CAST(Price AS decimal(10,2)) > 0
AND Customer_ID   IS NOT NULL;



/*
==============================================================================
 2. VALIDATION TESTS
==============================================================================

---------------------------------------------
-- 2.1. Table Inspection
---------------------------------------------
*/
SELECT TOP 5 *
FROM clean_sales;


---------------------------------------------
-- 2.2. NULL Validation
---------------------------------------------
SELECT *
FROM clean_sales
WHERE 
	Invoice       IS NULL
 OR StockCode     IS NULL
 OR [Description] IS NULL
 OR Quantity      IS NULL
 OR InvoiceDate   IS NULL
 OR Price         IS NULL
 OR Customer_ID   IS NULL;
-- No Results


---------------------------------------------
-- 2.3. Negative Values Validation
---------------------------------------------
SELECT *
FROM clean_sales
WHERE 
	Quantity <= 0
 OR Price <= 0;
 -- No Results

 
---------------------------------------------
-- 2.4. Cancellation & Accounting
--		Adjustments	Validation 
---------------------------------------------
-- Cancellation and Validation
SELECT *
FROM clean_sales
WHERE 
	Invoice LIKE 'C%'
 OR Invoice LIKE 'A%';
-- No Results


---------------------------------------------
-- 2.5. Duplicates Validation
---------------------------------------------
SELECT 
	Invoice,StockCode, [Description], Quantity, InvoiceDate, Price, Customer_ID, Country, Revenue, Transaction_Type,
	COUNT(*) AS duplicates
FROM clean_sales
GROUP BY Invoice,StockCode, [Description], Quantity, InvoiceDate, Price, Customer_ID, Country, Revenue, Transaction_Type
HAVING COUNT(*) > 1;
-- No Results


---------------------------------------------
-- 2.6. InvoiceDate Range Validation
---------------------------------------------
SELECT
	MIN(InvoiceDate) AS first_date,
	MAX(InvoiceDate) AS last_date
FROM clean_sales;
-- MIN = 2009-12-01 07:45 | MAX = 2010-12-09 20:01


---------------------------------------------
-- 2.7. Price Validation
---------------------------------------------
SELECT
	Transaction_Type,
	MIN(Price) AS lowest_price,
	MAX(Price) AS highest_price
FROM clean_sales
GROUP BY Transaction_Type
ORDER BY highest_price DESC;
/*
Transaction_Type lowest_price highest_price
---------------- ------------ -------------
ADJUSTMENT	     0.10	      10953.50
POSTAGE	         1.00	      850.00
PRODUCT	         0.03	      295.00
DISCOUNT	     1.00	      101.99
TEST	         1.00	      4.50
*/


---------------------------------------------
-- 2.8. Transaction_Type Validation
---------------------------------------------
SELECT
	Transaction_Type,
	COUNT(*) AS occurrences,
	SUM(Revenue) AS revenue
FROM clean_sales
GROUP BY Transaction_Type
ORDER BY revenue DESC;
/*
Transaction_Type occurrences revenue
---------------- ----------- ----------
PRODUCT	         399554	     8639657.20
ADJUSTMENT	     475	     103101.56
POSTAGE	         858	     54851.08
DISCOUNT	     5	         397.89
TEST	         10	         226.00
*/

SELECT 
	MIN(Quantity),
	MAX(Quantity)
FROM clean_sales
WHERE Transaction_Type = 'PRODUCT'
