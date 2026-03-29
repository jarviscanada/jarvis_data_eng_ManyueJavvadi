# Python Data Analytics  Retail Customer Insights

## Introduction

This project analyzes transactional data from a UK-based online gift retailer to better understand customer purchasing behavior. The business goal is to support the marketing team with actionable insights that can be used to improve customer engagement, retention, and revenue growth.

Using historical sales data, this analysis focuses on invoice behavior, monthly sales trends, customer activity, and customer segmentation. The results enable the business to identify high-value customers, detect seasonality, monitor cancellations, and design targeted marketing campaigns such as promotions, loyalty programs, and re-engagement strategies.

The work was implemented using Python and Jupyter Notebook, leveraging data analytics libraries to perform data wrangling, aggregation, visualization, and customer segmentation.

---

## Implementation

### Project Architecture

The overall architecture consists of:
- An LGS web application generating transactional data
- A PostgreSQL database storing retail transaction records
- A data analytics layer implemented in Python
- Jupyter Notebook used for data exploration, analysis, and visualization

Data is extracted from PostgreSQL into a Pandas DataFrame, transformed and analyzed within the notebook, and visualized to support business decision-making.

---

### Data Analytics and Wrangling

- Retail transactional data is loaded from PostgreSQL into Pandas
- Data quality checks are performed to understand missing values, duplicates, cancellations, and negative amounts
- Invoice-level aggregation is used to calculate invoice amounts
- Monthly metrics such as sales, growth, active users, placed orders, and cancellations are computed
- RFM (Recency, Frequency, Monetary) analysis is used to segment customers by value and engagement

**Notebook:**  
[Retail Data Analytics Notebook](./retail_data_analytics_wrangling.ipynb)

Using these analytics, LGS can:
- Identify high-value and loyal customers for premium offers
- Re-engage inactive or at-risk customers with targeted campaigns
- Monitor seasonal sales trends to plan promotions
- Reduce cancellations by understanding cancellation patterns
- Allocate marketing budgets more effectively based on customer segments

---

## Improvements

If more time were available, the following improvements could be made:
1. Build automated data pipelines to refresh analytics on a scheduled basis
2. Integrate customer demographics or product categories for deeper insights
3. Deploy dashboards using BI tools for real-time business monitoring

