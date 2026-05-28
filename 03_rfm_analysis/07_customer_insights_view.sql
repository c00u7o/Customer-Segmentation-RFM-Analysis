/*
==============================================================================
CUSTOMER INSIGHTS VIEW
==============================================================================
Purpose:
    This view consolidates customer-level behavioural, financial, and
    segmentation metrics to support executive-level reporting and Power BI dashboards.

Business Use:
    - Customer segmentation analysis
    - Revenue contribution tracking
    - Churn risk identification
    - Marketing strategy definition
    - Power BI reporting layer

Data Sources:
    - rfm_segments (customer segmentation model)
    - clean_sales (validated transactional dataset)
------------------------------------------------------------------------------
*/
USE rfm;
GO

/*
==============================================================================
VIEW: vw_customer_insights
==============================================================================
*/
CREATE OR ALTER VIEW vw_customer_insights AS

WITH customer_behavior AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Invoice) AS Orders,
        SUM(Revenue) AS Total_Revenue,
        SUM(Quantity) AS Total_Quantity,
        COUNT(DISTINCT StockCode) AS Unique_Products
    FROM clean_sales
    WHERE Transaction_Type = 'PRODUCT'
    GROUP BY Customer_ID
)

SELECT
    r.Customer_ID,
    r.Recency,
    r.Frequency,
    r.Monetary_Value,
    r.R_score,
    r.F_score,
    r.M_score,
    r.RFM_Score,
    r.Segment,
    cb.Orders,
    cb.Total_Revenue,
    cb.Total_Quantity,
    cb.Unique_Products,
    CAST(cb.Total_Revenue / cb.Orders AS DECIMAL(10,2)) AS AOV,
    CASE
        WHEN r.Recency <= 30 THEN 'LOW RISK'
        WHEN r.Recency <= 90 THEN 'MEDIUM RISK'
        WHEN r.Recency <= 180 THEN 'HIGH RISK'
        ELSE 'CRITICAL RISK'
    END AS Churn_Risk,
    CASE
        WHEN r.Segment = 'CHAMPIONS' THEN 'Reward VIP'
        WHEN r.Segment = 'LOYAL' THEN 'Upsell & Cross-sell'
        WHEN r.Segment = 'POTENTIAL LOYALIST' THEN 'Loyalty Program'
        WHEN r.Segment = 'RECENT CUSTOMERS' THEN 'Onboarding'
        WHEN r.Segment = 'PROMISING' THEN 'Engagement Boost'
        WHEN r.Segment = 'NEED ATTENTION' THEN 'Limited Offers'
        WHEN r.Segment = 'ABOUT TO SLEEP' THEN 'Win Back'
        WHEN r.Segment = 'AT RISK' THEN 'Personalised Outreach'
        WHEN r.Segment = 'CANNOT LOSE' THEN 'Priority Retention'
        WHEN r.Segment = 'HIBERNATING' THEN 'Brand Reactivation'
        WHEN r.Segment = 'LOST' THEN 'Do Not Target'
        ELSE 'Monitor'
    END AS Recommended_Action

FROM rfm_segments r
LEFT JOIN customer_behavior cb
    ON r.Customer_ID = cb.Customer_ID;

GO

/*
==============================================================================
VALIDATION QUERY 
==============================================================================
*/
SELECT *
FROM vw_customer_insights;