## Business Context

Luminara is an e-commerce retailer specializing in home décor, giftware, and everyday lifestyle products. Its catalog consists of a wide variety of affordable items, encouraging customers to make repeat purchases over time.

The company serves a diverse customer base across multiple regions and generates revenue through frequent, relatively low-value transactions.

While the business has accumulated a large volume of transactional data, it currently treats its customers as a homogeneous group, without distinguishing between high-value, loyal, or disengaged users.


## Problem Statement

Despite consistent sales, Luminara lacks a structured approach to understanding customer value and behavior.

In particular, the business does not differentiate between customers based on their contribution to revenue, engagement level, or likelihood to return.

This results in:

* Inefficient marketing efforts applied uniformly across all customers
* Missed opportunities to retain high-value customers
* Lack of targeted strategies to re-engage declining or inactive users
* Limited visibility into which customers drive the most business impact

Without customer segmentation, the company cannot effectively prioritize its marketing investments or maximize customer lifetime value.


## Project Objective

The objective of this analysis is to segment customers using the RFM (Recency, Frequency, Monetary) framework in order to evaluate their value, engagement, and purchasing behavior.

The analysis aims to identify distinct customer groups and translate these insights into actionable strategies that improve marketing effectiveness, customer retention, and overall revenue performance.


## Key Questions

* Which customer segments contribute the most to total revenue?
* Which segments represent the highest-value and most loyal customers?
* Which customers show signs of declining engagement or churn risk?
* Where should the business focus its marketing efforts to maximize return on investment?
* How can different customer segments be targeted to improve retention and increase spending?
* Which segments offer the greatest opportunity for revenue growth?


## Key Metrics / KPIs

* **Recency (R):** Days since last purchase
* **Frequency (F):** Number of transactions per customer
* **Monetary (M):** Total revenue per customer

Derived business KPIs:

* Revenue contribution by segment
* Average order value (AOV)
* Customer lifetime value (proxy using total spend)
* Repeat purchase behavior


## Dataset

The project uses the Online Retail II dataset containing transactional data from a UK-based online retailer between December 2009 and December 2010.

| Column       | Description |
|--------------|----------------|
| Invoice      | Unique Invoice Number |
| StockCode    | Product or Transaction Code |
| Description  | StockCode Description |
| Quantity     | Number of Items Purchased |
| InvoiceDate  | Date and Time of Transactions |
| Price        | Unit Price in GBP |
| Customer_ID  | Unique Customer Identifier |
| Country      | Customer's Country |


## Data Cleaning & Quality Assessment

The raw dataset contained several data quality issues that required validation and cleaning before performing the RFM analysis.

### Key Issues Identified

- Duplicate transactional records
- Missing and empty values across critical fields
- Negative and zero quantity values associated with cancelled transactions
- Negative and zero prices
- Invoice identifiers beginning with:
  - `C` → Cancelled transactions
  - `A` → Accounting adjustments
- Non-product StockCodes used for:
  - Discounts
  - Postage
  - Gift vouchers
  - Administrative adjustments
  - Test transactions
- All columns stored as `NVARCHAR`, requiring datatype conversion before analysis

## Data Cleaning Decisions

Based on the issues identified in the raw dataset, several data cleaning decisions were applied to ensure the dataset was reliable and suitable for RFM analysis.

### Transaction Classification

Instead of simply removing non-standard transactions, a new field (`transaction_type`) was created to preserve business context while separating operational entries from actual sales behavior.

This classification distinguishes between:
- Product purchases (valid RFM transactions)
- Cancellations and returns
- Discounts
- Postage and shipping fees
- Administrative adjustments
- Gift vouchers
- Test records

Only valid product-level transactions were retained for RFM calculation.

---

### Cancellation Handling

Transactions identified as cancellations (invoice numbers starting with `C`) were excluded from RFM calculations, as they represent returns rather than actual purchasing behavior.

This ensures that customer value is not negatively biased by refunded or reversed transactions.

---

### Data Type Standardization

All columns were originally stored as text (`NVARCHAR`) and were converted into appropriate analytical data types:

- `Quantity` → INTEGER  
- `Price` → DECIMAL  
- `InvoiceDate` → DATETIME2  
- `Customer_ID` → INTEGER  

This conversion ensures correct aggregation and time-based analysis.

---

### Data Filtering Rules

To maintain analytical accuracy and consistency, the following filtering rules were applied:

- Records with missing `Customer_ID` were removed
- Transactions with zero or negative `Quantity` were excluded
- Transactions with zero or negative `Price` were excluded
- Duplicate records were removed to prevent inflation of frequency and revenue metrics


## RFM Segmentation Methodology
### Overview

The RFM segmentation was implemented to transform transactional data into customer-level behavioral metrics. The process aggregates invoice-level data into a single record per customer and assigns relative scores based on purchasing behavior.

The final output is a structured dataset (rfm_segments) containing Recency, Frequency, Monetary Value, individual RFM scores, and a final segment classification.

---

### Feature Engineering Approach

The RFM model is built on three aggregated customer-level features:

Recency:
Calculated as the number of days between a customer’s most recent purchase and the latest date in the dataset.
Frequency:
Defined as the number of distinct invoices per customer.
Monetary Value:
Total revenue generated per customer, computed as the sum of Revenue.

Only transactions classified as Transaction_Type = 'PRODUCT' were included to ensure that operational or non-sales records (e.g., postage, adjustments, discounts) do not distort behavioral measures.

---

### Handling Distribution Skew in Frequency

During exploration of the Frequency variable, a significant skew was identified: a large proportion of customers had a frequency value of 1.

This created a clustering problem when using fixed binning methods (e.g. equal-width or quantile-based segmentation), as it compressed a large portion of the customer base into a single behavioral group.

To address this issue, a rank-based percentile approach (PERCENT_RANK) was used instead of NTILE.

This approach was selected because:

It preserves ordering while handling extreme skew
It distributes customers more smoothly across scoring thresholds
It reduces artificial clustering caused by repeated low-frequency values
It improves differentiation among both low- and high-engagement customers

---

### RFM Segment Definitions

After calculating RFM scores and generating the combined RFM_Score, customers were mapped into predefined behavioral segments.

These segments are based on standard RFM interpretation frameworks and represent distinct levels of engagement, value, and recency of interaction. Each segment groups customers with similar behavioral patterns in order to support targeted marketing and retention strategies.


| Segment                 | Description                                                                                                                  |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Champions**           | High recency, high frequency, and high monetary value customers. They represent the most valuable and engaged customer base. |
| **Loyal Customers**     | Customers with consistent purchasing behavior and strong revenue contribution, but not necessarily the most recent buyers.   |
| **Potential Loyalists** | Recent customers with more than one purchase and strong spending potential. Likely to become long-term valuable customers.   |
| **Recent Customers**    | Customers who purchased recently but have low frequency. They are in the early lifecycle stage.                              |
| **Promising Customers** | Recent buyers with low monetary value and limited repeat purchases. Show early engagement but low commitment.                |
| **Needing Attention**   | Customers with moderate historical value but declining or inconsistent recent activity. Require re-engagement.               |
| **About to Sleep**      | Customers with low recency, frequency, and monetary value. Engagement is declining and churn risk is increasing.             |
| **At Risk**             | Previously valuable customers who have not purchased recently. High-value churn risk segment.                                |
| **Can’t Lose Them**     | High-value customers (frequency and/or monetary) who have not returned recently. Require urgent retention focus.             |
| **Hibernating**         | Low engagement customers with long inactivity and low purchase behavior. Minimal recent interaction.                         |
| **Lost**                | Customers with consistently low RFM metrics and no meaningful recent activity. Very low likelihood of reactivation.          |

