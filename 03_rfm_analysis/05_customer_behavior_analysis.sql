/*
==============================================================================
CUSTOMER BEHAVIOR ANALYSIS
==============================================================================
Purpose:
    - Analyze customer purchasing behavior across RFM segments
    - Measure engagement, ordering patterns, and purchasing habits
    - Identify behavioral differences between customer groups
    - Support loyalty, cross-sell, and customer retention strategies

Key Business Questions:
    1. Which segments buy most frequently?
    2. Which segments have the highest Average Order Value (AOV)?
    3. Which segments show the strongest repeat purchase behavior?
    4. Which segments purchase larger basket sizes?
    5. Which segments purchase the widest variety of products?
------------------------------------------------------------------------------
*/
USE rfm;
GO


/*
==============================================================================
1. Purchase Frequency by Segment
==============================================================================
Purpose:
    - Measure how often customers from each segment purchase
    - Identify highly engaged customer groups
------------------------------------------------------------------------------
*/
SELECT
    Segment,
    COUNT(*) AS Customer_Count,
    AVG(Frequency) AS Avg_Purchase_Frequency,
    MIN(Frequency) AS Min_Frequency,
    MAX(Frequency) AS Max_Frequency
FROM rfm_segments
GROUP BY Segment
ORDER BY Avg_Purchase_Frequency DESC;


/*
==============================================================================
2. Average Order Value (AOV) by Segment
==============================================================================
Purpose:
    - Measure the average revenue generated per order
    - Identify segments with higher spending behavior
------------------------------------------------------------------------------
*/
WITH customer_orders AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Invoice) AS Orders,
        SUM(Revenue) AS Total_Revenue
    FROM clean_sales
    WHERE Transaction_Type = 'PRODUCT'
    GROUP BY Customer_ID
)

SELECT
    r.Segment,
    CAST(
    SUM(c.Total_Revenue) / SUM(c.Orders)
    AS DECIMAL(10,2)) AS AVG_Order_Value 
FROM customer_orders AS c
LEFT JOIN rfm_segments As r
    ON c.Customer_ID =r.Customer_ID
GROUP BY Segment
ORDER BY AVG_Order_Value DESC;

/*
==============================================================================
3. Repeat Purchase Rate by Segment
==============================================================================
Purpose:
    - Measure the proportion of customers with multiple purchases
    - Evaluate customer retention and loyalty behavior
------------------------------------------------------------------------------
*/
SELECT
    Segment,
    COUNT(*) AS Total_Customers,
    SUM(
        CASE
            WHEN Frequency > 1 THEN 1
            ELSE 0
        END) AS Repeat_Customers,
    CAST(
        SUM(
            CASE 
                WHEN Frequency > 1 THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*) 
    AS DECIMAL(10,2)) AS Repeat_Purchase_Rate
FROM rfm_segments
GROUP BY Segment
ORDER BY Repeat_Purchase_Rate DESC;


/*
==============================================================================
4. Average Basket Size by Segment
==============================================================================
Purpose:
    - Measure the average number of products purchased per order
    - Identify segments with larger purchasing baskets
------------------------------------------------------------------------------
*/
WITH invoice_basket AS (
    SELECT 
        Customer_ID,
        Invoice,
        SUM(Quantity) AS Basket_Size
    FROM clean_sales
    WHERE Transaction_Type = 'PRODUCT'
    GROUP BY Customer_ID, Invoice
)

SELECT 
    r.Segment,
    AVG(i.Basket_Size) As AVG_Basket_Size
FROM invoice_basket As i
LEFT JOIN rfm_segments AS r
    ON i.Customer_ID = r.Customer_ID
GROUP BY r.Segment
ORDER BY AVG_Basket_Size;


/*
==============================================================================
5. Product Diversity by Segment
==============================================================================
Purpose:
    - Measure the variety of products purchased by each segment
    - Identify segments with broader purchasing behavior
------------------------------------------------------------------------------
*/
WITH customer_product_diversity AS (
    SELECT 
        Customer_ID,
        COUNT(DISTINCT StockCode) AS Unique_Products
    FROM clean_sales
    WHERE Transaction_Type = 'PRODUCT'
    GROUP BY Customer_ID
)

SELECT
    r.Segment,
    AVG(Unique_Products) AS AVG_Unique_Products
FROM customer_product_diversity AS c
LEFT JOIN rfm_segments As r
    ON c.Customer_ID = r.Customer_ID
GROUP BY Segment
ORDER BY AVG_Unique_Products DESC;
