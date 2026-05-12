/*
==============================================================================
SEGMENT REVENUE ANALYSIS
==============================================================================
Purpose:
    - Evaluate the financial contribution of each customer segment
    - Identify the segments generating the highest business value
    - Measure revenue concentration across the customer base
    - Support retention prioritization using customer value analysis

Key Business Questions:
    1. Which segments generate the most revenue?
    2. Which customers are the most valuable?
    3. Is revenue concentrated among a small group of customers?
    4. Which segments deserve retention investment?
------------------------------------------------------------------------------
*/
USE rfm;
GO


/*
==============================================================================
1. Revenue Contribution by Segment
==============================================================================
Purpose:
    - Measure total revenue contribution by segment
    - Identify high-impact customer groups
    - Compare customer volume vs financial contribution
------------------------------------------------------------------------------
*/
SELECT 
    COUNT(*) AS Customer_Count,
    CAST (SUM(Monetary_Value) AS DECIMAL(10,2)) AS Total_Revenue,
    CAST (AVG(Monetary_Value) AS DECIMAL(10,2)) AS Avg_Customer_Value,
    CONCAT(
        CAST(
            SUM(Monetary_Value) * 100.0 / SUM(SUM(Monetary_Value)) OVER()
        AS DECIMAL(10,2)),
    '%') AS Revenue_Percentage
FROM rfm_segments
GROUP BY Segment
ORDER BY Total_Revenue DESC;


/*
==============================================================================
2. Top High-Value Customers
==============================================================================
Purpose:
    - Identify the customers generating the highest revenue
    - Highlight VIP customers for retention and loyalty strategies
------------------------------------------------------------------------------
*/
SELECT TOP 20
    Customer_ID,
    Segment,
    Frequency,
    Monetary_Value,
    Recency
FROM rfm_segments
ORDER BY Monetary_Value DESC;


/*
==============================================================================
3. Revenue Concentration Analysis (Pareto Analysis)
==============================================================================
Purpose:
    - Evaluate whether a small percentage of customers
      generates the majority of revenue
    - Support prioritization of retention investments
------------------------------------------------------------------------------
*/
WITH customer_revenue AS(
    SELECT 
        Customer_ID,
        Segment,
        Monetary_Value,
        SUM(Monetary_Value) OVER(
            ORDER BY Monetary_value DESC
        ) AS cumulative_revenue,
        SUM(Monetary_Value) OVER() AS total_revenue,
        ROW_NUMBER() OVER(
            ORDER BY Monetary_Value DESC
        ) AS customer_rank,
        COUNT(*) OVER() AS total_customers
    FROM rfm_segments
)

SELECT 
    Customer_ID,
    Segment,
    Monetary_Value,
    CONCAT(
        CAST(
            cumulative_revenue * 100.0 / total_revenue
        AS decimal(10,2)),
    '%') AS cumulative_revenue_pct,
    CONCAT(
        CAST(
            customer_rank * 100.0 / total_customers
        AS DECIMAL(10,2)),
    '%') AS customer_pct
FROM customer_revenue
ORDER BY Monetary_Value DESC;


/*
==============================================================================
4. Retention Priority Segments
==============================================================================
Purpose:
    - Identify high-value segments with elevated churn risk
    - Support retention-focused marketing investment
------------------------------------------------------------------------------
*/
SELECT 
    COUNT(*) AS Customers,
    AVG(Recency) AS AVG_Recency,
    AVG(Frequency) AS AVG_Frequency,
    CAST(
        AVG(Monetary_Value)
    AS DECIMAL(10,2)) AS AVG_Monetary_Value,
    SUM(Monetary_Value) AS Total_Revenue
FROM rfm_segments
WHERE Segment IN (
    'ABOUT TO SLEEP',
    'AT RISK',
    'CANNOT LOSE',
    'PROMISING'
    )
GROUP BY Segment
ORDER BY Total_Revenue DESC;
