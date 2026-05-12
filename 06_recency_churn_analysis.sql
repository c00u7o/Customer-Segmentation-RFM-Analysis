/*
==============================================================================
RECENCY & CHURN ANALYSIS
==============================================================================
Purpose:
    - Analyze customer inactivity and churn risk across segments
    - Identify declining engagement patterns
    - Measure potential revenue exposure from inactive customers
    - Support customer retention and reactivation strategies

Key Business Questions:
    1. Which customer segments show declining engagement?
    2. Which high-value customers stopped purchasing?
    3. Which segments represent the highest churn risk?
    4. How much revenue is currently at risk?
------------------------------------------------------------------------------
*/
USE rfm;
GO


/*
==============================================================================
1. Declining Customer Segments
==============================================================================
Purpose:
    - Identify segments with high inactivity levels
    - Evaluate engagement deterioration using Recency
------------------------------------------------------------------------------
*/
SELECT
    Segment,
    COUNT(*) AS Customer_Count,
    AVG(Recency) AS Avg_Recency,
    MIN(Recency) AS Min_Recency,
    MAX(Recency) AS Max_Recency,
    CAST(
        AVG(Monetary_Value) 
    AS DECIMAL(10,2)) AS Avg_Monetary_Value
FROM rfm_segments
GROUP BY Segment
ORDER BY Avg_Recency DESC;


/*
==============================================================================
2. High-Value Customers at Churn Risk
==============================================================================
Purpose:
    - Identify valuable customers with long inactivity periods
    - Support proactive retention and reactivation campaigns
------------------------------------------------------------------------------
*/
SELECT TOP 50
    Customer_ID,
    Segment,
    Recency,
    Frequency,
    Monetary_Value
FROM rfm_segments
WHERE Segment IN (
    'AT RISK',
    'CANNOT LOSE',
    'ABOUT TO SLEEP'
)
ORDER BY Monetary_Value DESC, Recency DESC;


/*
==============================================================================
3. Churn Risk Matrix
==============================================================================
Purpose:
    - Categorize customers by churn severity
    - Evaluate customer distribution across churn-risk levels
------------------------------------------------------------------------------
*/
SELECT
    CASE
        WHEN Recency <= 30 THEN 'LOW RISK'
        WHEN Recency <= 90 THEN 'MEDIUM RISK'
        WHEN Recency <= 180 THEN 'HIGH RISK'
        ELSE 'CRITICAL RISK'
    END AS Churn_Risk_Level,
    COUNT(*) AS Customer_Count,
    CAST(
        AVG(Monetary_Value)
    AS DECIMAL(10,2)) AS Avg_Customer_Value,
    SUM(Monetary_Value) AS Total_Revenue_Exposure
FROM rfm_segments
GROUP BY
    CASE
        WHEN Recency <= 30 THEN 'LOW RISK'
        WHEN Recency <= 90 THEN 'MEDIUM RISK'
        WHEN Recency <= 180 THEN 'HIGH RISK'
        ELSE 'CRITICAL RISK'
    END
ORDER BY Total_Revenue_Exposure DESC;


/*
==============================================================================
4. Revenue at Risk
==============================================================================
Purpose:
    - Measure the amount of revenue associated with inactive customers
    - Quantify potential business exposure from churn
------------------------------------------------------------------------------
*/
SELECT
    Segment,
    COUNT(*) AS Customers_At_Risk,
    SUM(Monetary_Value) AS Revenue_At_Risk,
    CAST(
        AVG(Monetary_Value)
    AS DECIMAL(10,2)) AS Avg_Customer_Value,
    CONCAT(    
        CAST(
            SUM(Monetary_Value) * 100.0 / SUM(SUM(Monetary_Value)) OVER()
        AS DECIMAL(10,2)),
    '%') AS Revenue_At_Risk_Pct
FROM rfm_segments
WHERE Segment IN (
    'AT RISK',
    'CANNOT LOSE',
    'HIBERNATING',
    'ABOUT TO SLEEP'
)
GROUP BY Segment
ORDER BY Revenue_At_Risk DESC;