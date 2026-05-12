/*
==============================================================================
DATA CLEANING & QUALITY ASSESSMENT: online_retail_II
==============================================================================
Purpose:
    - Assess the quality and structure of the raw transactional dataset
    - Identify duplicates, missing values, invalid records, and anomalies

Queries: 
	1. Table Inspection
	2. Schema & Data Types
	3. Row Count
	4. Duplicate Row Checks
	5. Empty & NULL Values
	6. DATA QUALITY ISSUES
	- - 6.1. Invoice     Validation
	- - 6.2. StockCode   Validation
	- - 6.3. Description Validation
	- - 6.4. Quantity    Validation
	- - 6.5. InvoiceDate Validation
	- - 6.6. Price       Validation
	- - 6.7. Customer_ID Validation
	- - 6.8. Country     Validation 
------------------------------------------------------------------------------
*/
USE rfm;
GO


---------------------------------------------
-- 1. Table Inspection
---------------------------------------------
SELECT TOP 5 *
FROM online_retail_II;
/*
Invoice	StockCode Description                       Quantity InvoiceDate        Price Customer_ID Country
------- --------- --------------------------------- -------- ----------------   ----- ----------- --------------
529133	84912A	  PINK ROSE WASHBAG	                3	     10/26/2010 14:47	3.36  NULL	      United Kingdom
529133	84912B	  GREEN ROSE WASHBAG	            3	     10/26/2010 14:47	3.36  NULL	      United Kingdom
529133	84970L	  SINGLE HEART ZINC T-LIGHT HOLDER	1	     10/26/2010 14:47	2.13  NULL	      United Kingdom
529133	84970S	  HANGING HEART ZINC T-LIGHT HOLDER	1	     10/26/2010 14:47	2.13  NULL	      United Kingdom
529133	84978	  HANGING HEART JAR T-LIGHT HOLDER	3	     10/26/2010 14:47	2.51  NULL	      United Kingdom
*/


---------------------------------------------
-- 2. Schema & Data Types
---------------------------------------------
SELECT 
	COLUMN_NAME,
	DATA_TYPE,
	IS_NULLABLE,
	CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'online_retail_II';
/*
COLUMN_NAME	DATA_TYPE IS_NULLABLE CHARACTER_MAXIMUM_LENGTH
----------- --------- ----------- ------------------------
Invoice 	nvarchar  YES	      50
StockCode	nvarchar  YES	      50
Description	nvarchar  YES	      50
Quantity	nvarchar  YES	      50
InvoiceDate	nvarchar  YES	      50
Price   	nvarchar  YES	      50
Customer_ID	nvarchar  YES	      50
Country 	nvarchar  YES	      50
*/


---------------------------------------------
-- 3. Row Count
---------------------------------------------
SELECT COUNT(*) AS total_rows
FROM online_retail_II;
-- 525461 rows


---------------------------------------------
-- 4. Duplicate Row Checks
---------------------------------------------
SELECT SUM(duplicates -1) AS true_duplicate_rows
FROM (
	SELECT 
		Invoice, StockCode, [Description], Quantity, InvoiceDate, Price, Customer_ID, Country,
		COUNT(*) AS duplicates
	FROM online_retail_II
	GROUP BY Invoice, StockCode, [Description], Quantity, InvoiceDate, Price, Customer_ID, Country
	HAVING COUNT(*) > 1
) t;
-- 6865 duplicate rows !


---------------------------------------------
-- 5. Empty & NULL Values
---------------------------------------------
SELECT *
FROM online_retail_II
WHERE 
	Invoice IS NULL OR TRIM(Invoice) = ''
 OR	StockCode IS NULL OR TRIM(StockCode) = ''
 OR [Description] IS NULL OR TRIM([Description]) = ''
 OR Quantity IS NULL OR TRIM(Quantity) = ''
 OR InvoiceDate IS NULL OR TRIM(InvoiceDate) = ''
 OR Price IS NULL OR TRIM(Price) = ''
 OR Customer_ID IS NULL OR TRIM(Customer_ID) = ''
 OR Country IS NULL OR TRIM(Country) = '';
-- 107.927 rows contain at least one null or empty critical field


/*
==============================================================================
 6.DATA QUALITY ISSUES
==============================================================================

---------------------------------------------
-- 6.1. Invoice Validation
---------------------------------------------
*/
SELECT 
	LEN(Invoice) AS Invoice_length,
	COUNT(*) AS occurrences
FROM online_retail_II
GROUP BY LEN(Invoice)
ORDER BY LEN(Invoice);
/*
Invoice_length occurrences
-------------- -----------
6          	   515252
7       	   10209
*/

SELECT DISTINCT
	LEFT(Invoice, 1) AS letter
FROM online_retail_II
WHERE LEN(Invoice) = 7;
-- A (Accounting Adjustments) | C (Cancelled Transactions)

SELECT *
FROM online_retail_II
WHERE Invoice LIKE 'C%';

SELECT *
FROM online_retail_II
WHERE Invoice LIKE 'A%';


---------------------------------------------
-- 6.2. StockCode Validation
---------------------------------------------
SELECT DISTINCT StockCode, [Description]
FROM online_retail_II
WHERE StockCode NOT LIKE '[0-9]%';

SELECT *
FROM online_retail_II
WHERE StockCode = 'D'


---------------------------------------------
-- 6.3. Description Validation
---------------------------------------------
SELECT 
	StockCode, 
	COUNT(DISTINCT [Description]) AS distinct_descriptions 
FROM online_retail_II
GROUP BY StockCode
HAVING COUNT(DISTINCT [Description]) > 1;

SELECT * FROM online_retail_II WHERE StockCode = '15056N';


---------------------------------------------
-- 6.4. Quantity Validation
---------------------------------------------
SELECT 
	MIN(CAST(Quantity AS int)) AS min_quantity,
	MAX(CAST(Quantity AS int)) AS max_quantity
FROM online_retail_II;
-- MIN = -9600 | MAX = 19152

SELECT *
FROM online_retail_II
WHERE CAST(Quantity AS int) <= 0;
-- 12.326 row

SELECT *
FROM online_retail_II
ORDER BY CAST(Quantity AS int) DESC;


---------------------------------------------
-- 6.5. InvoiceDate Validation
---------------------------------------------
SELECT 
	MIN(CAST(InvoiceDate AS datetime2)) AS min_date,
	MAX(CAST(InvoiceDate AS datetime2)) AS max_date
FROM online_retail_II;
-- MIN = 2009-12-01 07:45 | MAX = 2010-12-09 20:01


---------------------------------------------
-- 6.6. Price Validation
---------------------------------------------
SELECT 
	MIN(CAST(Price AS decimal(10,2))) AS min_price,
	MAX(CAST(Price AS decimal(10,2))) as max_price
FROM online_retail_II
-- MIN = -53594,36$ | MAX = 25111,09$

SELECT *
FROM online_retail_II
WHERE CAST(Price AS decimal(10,2)) <= 0;
-- 37004 rows


---------------------------------------------
-- 6.7. Customer_ID Validation
---------------------------------------------
SELECT 
	Customer_ID,
	COUNT(DISTINCT Invoice) AS orders
FROM online_retail_II
WHERE Customer_ID IS NOT NULL AND TRIM(Customer_ID) != ''
GROUP BY Customer_ID
ORDER BY orders DESC;


---------------------------------------------
-- 6.8. Country Validation
---------------------------------------------
SELECT DISTINCT 
	Country,
	COUNT(*) AS ocurrences
FROM online_retail_II
GROUP BY Country
ORDER BY ocurrences DESC;