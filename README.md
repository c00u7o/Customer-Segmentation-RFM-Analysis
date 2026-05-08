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


| Column       | Data Quality Issues |
|--------------|---------------------|
| Invoice      | Contains cancellations (prefix 'C') and accounting adjustments (prefix 'A') |
| StockCode    | Includes non-product codes (discounts, postage, gift vouchers, adjustments, tests) |
| Description  | Missing values and inconsistent descriptions for some StockCodes |
| Quantity     | Negative values due to cancellations and returns |
| InvoiceDate  | Stored as NVARCHAR, requires conversion to datetime |
| Price        | Contains zero and negative values |
| Customer_ID  | Missing values and blanks present |
| Country      | No major issues, but requires standardization |

### Cleaning Decisions

To ensure analytical accuracy and prevent distortions in customer segmentation:

- Duplicate rows were removed
- Rows with missing critical fields were excluded
- Only positive quantity and price values were retained
- Cancelled transactions were excluded from the final RFM dataset
- A new column called `transaction_type` was created to classify non-product transactions such as:
  - `DISCOUNT`
  - `POSTAGE`
  - `ADJUSTMENT`
  - `GIFT_VOUCHER`
  - `TEST`
  - `PRODUCT`
- Datatypes were converted into appropriate analytical formats:
  - `INT`
  - `DECIMAL`
  - `DATETIME2`

These cleaning steps ensured that the final dataset accurately represented real customer purchasing behavior for RFM segmentation.

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

---

### Feature Engineering

A new column (`transaction_type`) was introduced to categorize transactions and improve interpretability of the dataset.

This allows separation of true product sales from operational or non-commercial records while maintaining full dataset transparency.
