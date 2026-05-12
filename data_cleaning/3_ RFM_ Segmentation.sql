/*
==============================================================================
RFM SEGMENTATION
==============================================================================
Purpose:
    - Build a customer-level RFM segmentation dataset
    - Measure customer purchasing behavior using:
        • Recency
        • Frequency
        • Monetary Value
    - Score customers based on purchasing patterns
    - Classify customers into business-oriented segments
------------------------------------------------------------------------------
*/
USE rfm;
GO

/*
==============================================================================
    TABLE CREATION 
==============================================================================
*/
DROP TABLE IF EXISTS  rfm_segments
GO

CREATE TABLE rfm_segments (
    Customer_ID INT,
    Recency INT,
    Frequency INT,
    Monetary_Value DECIMAL(10,2),
    R_score INT,
    F_score INT,
    M_score INT,
    RFM_Score VARCHAR(50),
    Segment VARCHAR(50)
);

/*
==============================================================================
RFM Metrics and Segments & Data Insertion
==============================================================================
*/
WITH customer_metrics AS (
    SELECT
        Customer_ID,
        DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM clean_sales)) AS Recency,
        COUNT(DISTINCT Invoice) AS Frequency,
        SUM(Revenue) AS Monetary_Value
    FROM clean_sales
    WHERE 
        Transaction_Type = 'PRODUCT'
    GROUP BY Customer_ID
),

rfm_calc AS (
    SELECT
        Customer_ID,
        Recency,
        Frequency,
        Monetary_Value,
        CASE    
            WHEN PERCENT_RANK() OVER (ORDER BY Recency) >= 0.8 THEN 1
            WHEN PERCENT_RANK() OVER (ORDER BY Recency) >= 0.6 THEN 2
            WHEN PERCENT_RANK() OVER (ORDER BY Recency) >= 0.4 THEN 3
            WHEN PERCENT_RANK() OVER (ORDER BY Recency) >= 0.2 THEN 4
            ELSE 5
        END AS R_Score,
        CASE 
            WHEN PERCENT_RANK() OVER (ORDER BY Frequency) >= 0.8 THEN 5
            WHEN PERCENT_RANK() OVER (ORDER BY Frequency) >= 0.6 THEN 4
            WHEN PERCENT_RANK() OVER (ORDER BY Frequency) >= 0.4 THEN 3
            WHEN PERCENT_RANK() OVER (ORDER BY Frequency) >= 0.2 THEN 2
            ELSE 1
        END AS F_score,
        CASE 
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary_value) >= 0.8 THEN 5
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary_value) >= 0.6 THEN 4
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary_value) >= 0.4 THEN 3
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary_value) >= 0.2 THEN 2
            ELSE 1
        END AS M_Score
    FROM customer_metrics
),

rfm_scores AS (
    SELECT  
        Customer_ID,
        Recency,
        Frequency,
        Monetary_Value,
        R_score,
        F_score,
        M_score,
        CONCAT(R_score, F_score, M_score) AS RFM_Score
    FROM rfm_calc
),

rfm_segment AS (
    SELECT
        Customer_ID,
        Recency,
        Frequency,
        Monetary_Value,
        R_score,
        F_score,
        M_score,
        RFM_Score,
        CASE
            WHEN RFM_Score IN (555,554,544,545,454,455,445) THEN 'CHAMPIONS'
            WHEN RFM_Score IN (543,444,435,355,354,345,344,335) THEN 'LOYAL'
            WHEN RFM_Score IN (553,551,552,541,542,533,532,531,452,451,442,441,431,453,433,432,423,353,352,351,342,341,333,323) THEN 'POTENCIAL LOYALIST'
            WHEN RFM_Score IN (512,511,422,421,412,411,311) THEN 'RECENT CUSTOMERS'
            WHEN RFM_Score IN (525,524,523,522,521,515,514,513,425,424,413,414,415,315,314,313) THEN 'PROMISING'
            WHEN RFM_Score IN (535,534,443,434,343,334,325,324) THEN 'NEED ATTENTION'
            WHEN RFM_Score IN (331,321,312,221,213,231,241,251) THEN 'ABOUT TO SLEEP'
            WHEN RFM_Score IN (255,254,245,244,253,252,243,242,235,234,225,224,153,152,145,143,142,135,134,133,124,124) THEN 'AT RISK'
            WHEN RFM_Score IN (155,154,144,214,215,115,114,113) THEN 'CANNOT LOSE'
            WHEN RFM_Score IN (332,322,231,241,251,233,232,223,222,132,123,122,212,211) THEN 'HIBERNATING'
            WHEN RFM_Score IN (111,112,121,131,141,151) THEN 'LOST'
            ELSE 'CUSTOMERS'
        END AS segment
  FROM rfm_scores
)

INSERT INTO rfm_segments
SELECT *
FROM rfm_segment


