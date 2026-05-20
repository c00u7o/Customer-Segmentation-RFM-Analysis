# Luminara RFM Customer Segmentation: Data-Driven Retention & Revenue Optimisation

[![Dashboard Overview](Dashboard_Overview.png)](Luminara_RFM_Dashboard.pbix)

## 1. Project Background & Overview

### Business Context

Luminara is a global e-commerce retailer specialising in home décor, giftware, and lifestyle products. Characterised by a high volume of relatively low-value transactions, the company manages a vast and diverse international customer base. Historically, Luminara has operated under a "one-size-fits-all" marketing strategy, treating its entire database as a homogeneous group. This lack of differentiation has prevented the business from identifying its most valuable patrons or intervening when high-value relationships begin to sour.

### Problem Statement

The absence of a structured segmentation model creates significant strategic risks:

* **Inefficient Capital Allocation:** Marketing spend is distributed uniformly rather than being prioritised for high-ROI segments.
* **High-Value Churn Vulnerability:** Without visibility into declining engagement, "whale" customers churn without any proactive retention effort.
* **Missed Growth Opportunities:** There is no automated framework to nurture "Promising" or "Recent" customers into long-term loyalists.

### Project Objectives

This analysis implements the RFM (Recency, Frequency, Monetary) framework to transform millions of rows of transactional data into a strategic roadmap. The primary goals are to:

1. **Segment the base** into distinct behavioural groups.
2. **Quantify revenue concentration** and identify high-dependency risks.
3. **Execute targeted retention** and re-engagement workflows based on customer value.

### KPI Definitions

The segmentation relies on three primary metrics and one derived KPI:

| Metric | Definition | Business Importance |
|---|---|---|
| Recency | Days since the customer's last purchase. | Primary indicator of current engagement and immediate churn risk. |
| Frequency | Number of distinct invoices/transactions. | Measures brand stickiness and repeat purchase behaviour. |
| Monetary Value | Total revenue generated per customer. | Identifies the financial contribution and lifetime value (LTV). |
| Avg. Order Value (AOV) | Total revenue divided by frequency. | Measures basket efficiency and spending capacity per visit. |
---
## 2. Data Structure & Metadata

### Dataset Overview

The analysis utilised the "Online Retail II" dataset (Dec 2009 – Dec 2010). A critical technical challenge was that all columns were originally stored as `NVARCHAR` (text), requiring a robust type-casting phase to enable mathematical aggregation.

| Column | Description | Data Type |
|---|---|---|
| Invoice | Unique 6-digit identifier for each transaction. | `NVARCHAR` |
| StockCode | Unique product or transaction code. | `NVARCHAR` |
| Description | Textual description of the item. | `NVARCHAR` |
| Quantity | Number of units purchased. | `INTEGER` |
| InvoiceDate | Date and time the transaction was generated. | `DATETIME2` |
| Price | Product price per unit in GBP (£). | `DECIMAL` |
| Customer_ID | Unique identifier for each customer. | `INTEGER` |
| Country | Customer's country of residence. | `NVARCHAR` |

### Data Cleaning & Technical Nuance

To maintain a "Senior Analytics" standard of rigour, data was not merely purged but classified to preserve business context:

* **Transaction Classification:** A new `transaction_type` field was engineered to distinguish between 'PRODUCT' sales, 'CANCELLATION' (C-prefix), 'ADJUSTMENT' (A-prefix), 'DISCOUNT', and 'POSTAGE'.
* **Contextual Filtering:** Only 'PRODUCT' type records with positive prices and quantities were passed to the RFM model. This ensures frequency and monetary metrics reflect genuine consumer behaviour rather than administrative corrections.
* **Methodology:** We utilised `PERCENT_RANK` for frequency scoring rather than standard `NTILE`. Exploratory analysis revealed a significant distribution skew where a large proportion of customers had a frequency of 1. `NTILE` would have caused "artificial clustering," forcing different behaviours into the same bucket. `PERCENT_RANK` provides the necessary granularity to differentiate engagement levels accurately.
---
## 3. Executive Summary

### High-Level Findings

The analysis reveals a **High-Dependency** Risk regarding revenue concentration. The **'CHAMPIONS'** segment—a small group of 808 customers—generates a staggering **63.26% (£5,465,483.55)** of total revenue. The business is currently survival-dependent on this elite tier; any significant churn within this group would be catastrophic.

### Revenue Exposure & Churn Risk

Beyond the top tier, there is massive "Revenue at Risk." The **'AT RISK'** segment represents **60.25%** of the total revenue-at-risk pool. Recovering this segment should be the primary focus for the marketing team's ROI, as it holds £806k in historical value that is currently trending toward permanent loss.

### Strategic Priorities

1. **Protect the Core:** VIP exclusivity for Champions to mitigate dependency risk.
2. **Focus Recovery:** Targeted re-engagement for the **'AT RISK'** segment for maximum revenue salvage.
3. **Reallocate Spend:** Move **'LOST'** and **'HIBERNATING'** customers to low-cost automation to improve overall marketing ROI.
---
## 4. Insights Deep Dive

### Segment Revenue Contribution

The disparity in value across the 12 identified segments highlights the failure of a homogeneous marketing approach:

| Segment | Customer Count | Total Revenue (£) | Revenue % |
|---|---:|---:|---:|
| CHAMPIONS | 808 | 5,465,483.55 | 63.26% |
| LOYAL | 387 | 896,221.80 | 10.37% |
| AT RISK | 378 | 806,580.01 | 9.34% |
| NEED ATTENTION | 226 | 282,802.90 | 3.27% |
| HIBERNATING | 658 | 270,735.26 | 3.13% |
| POTENTIAL LOYALIST | 344 | 223,763.92 | 2.59% |
| PROMISING | 207 | 194,284.89 | 2.25% |
| CANNOT LOSE | 104 | 187,740.79 | 2.17% |
| LOST | 558 | 119,350.49 | 1.38% |
| RECENT CUSTOMERS | 420 | 96,602.22 | 1.12% |
| ABOUT TO SLEEP | 190 | 73,654.85 | 0.85% |
| CUSTOMERS | 5 | 22,436.52 | 0.26% |

### Behavioural Profiles & Archetypes

Understanding the why behind the numbers allows for tailored messaging:

| Segment | Avg. Freq | Avg. Order Value (AOV) | Repeat Purchase Rate | Avg. Unique Products |
|---|---:|---:|---:|---:|
| CHAMPIONS | 12 | £457.19 | 100% | 148 |
| AT RISK | 4 | £505.61 | 100% | 72 |
| CANNOT LOSE | 2 | £1,116.71 | 24.04% | 51 |
| LOYAL | 5 | £426.66 | 100% | 94 |
| POTENTIAL LOYALIST | 2 | £255.39 | 100% | 46 |
| PROMISING | 1 | £684.06 | 58.45% | 47 |

### Segment Characterisation

* **CHAMPIONS (Power Users):** These are your brand advocates. With 148 unique products on average, they are highly diversified and frequent shoppers.
* **AT RISK (Priority Recovery):** These customers have high historical engagement but haven't purchased in ~133 days. They represent the largest single opportunity for revenue recovery (£806k).
* **CANNOT LOSE (Former Whales):** While their frequency is lower (2), their AOV is the highest in the dataset at £1,116. These are infrequent but massive spenders who have stopped returning. Their loss is qualitatively more damaging than smaller, frequent churners.

*** Churn Risk Matrix

| Churn Risk Level | Customer Count | Revenue Exposure (£) | Risk Profile |
|---|---:|---:|---|
| Low Risk | 1,614 | 5,894,766.07 | Recently active; primary revenue core. |
| Medium Risk | 1,261 | 1,707,652.88 | Declining frequency; requires monitoring. |
| High Risk | 599 | 552,246.83 | Long-term inactivity; likely disengaged. |
| Critical Risk | 811 | 484,991.42 | High recency; likely already churned. |
---
## 5. Recommendations

### I. High-Value Retention (Champions & Loyal)

Luminara must protect the 63%+ revenue stream through exclusivity rather than aggressive discounting, which could erode brand value.

* **Actions:** Deploy VIP-only loyalty tiers, early access to new collections, and priority customer support.
* **Expected Business Impact:** Stabilisation of the £5.4M core revenue and enhanced LTV through non-monetary incentives.

### II. Growth & Conversion (Potential Loyalists & Promising)

Focus on moving these "mid-tier" buyers up the value chain by increasing purchase frequency.

* **Actions:** Implement automated "second purchase" email triggers and basket-size incentives (e.g., "Spend £20 more for free shipping") to boost AOV.
* **Expected Business Impact:** Expansion of the 'Loyal' segment and higher early-lifecycle retention.

### III. Churn Prevention (At Risk & Cannot Lose)

This is the highest priority for immediate revenue impact. Automated churn mitigation is essential.

* **Actions:** Trigger **lifecycle-triggered re-engagement** workflows for customers hitting 90-day inactivity thresholds. Use time-limited "win-back" offers specifically for the high-AOV 'Cannot Lose' segment.
* **Expected Business Impact:** Recovery of up to **£806k (60.25% of risk pool)** in historical revenue.

### IV. Low-Value Management (Hibernating & Lost)

Stop the "bleeding" of marketing resources on segments with low reactivation probability.

* **Actions:** Transition these groups to quarterly, low-cost automated newsletters and generic seasonal reminders.
* **Expected Business Impact:** Improved marketing ROI by reallocating budget toward segments with a higher probability of conversion.
---
## Closing Statement

By transitioning from a homogeneous view to a structured RFM framework, Luminara gains **Clarity over Complexity**. These insights provide a clear strategic roadmap: protect the £5.4M core, recover the £806k at-risk pool, and drive efficiency through automated lifecycle management. This shift transforms raw data into a sustainable engine for revenue growth.
