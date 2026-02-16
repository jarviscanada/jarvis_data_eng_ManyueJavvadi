# Spark Data Analytics - Retail and Economic Insights

## Introduction
This project demonstrates scalable data analytics using **Apache Spark (PySpark)** on distributed computing platforms. The objective is to re-architect previous Python/Pandas analytics to handle large-scale datasets, evaluating two Spark environments: **Databricks (Azure)** and **Zeppelin (GCP Dataproc/Hadoop)**.

**Key Components:**
1. **Retail Customer Analytics (Databricks)**: UK online gift retailer transaction analysis for marketing insights
2. **Economic Indicators Analysis (Zeppelin)**: World Development Indicators (WDI) data exploration using PySpark

By migrating from single-machine Python to distributed Spark, this project showcases enterprise-scale data processing capabilities.

## Implementation

### Project Architecture
- **Databricks (Azure)**: Cloud-managed Spark platform with integrated notebooks and visualization
- **Zeppelin (GCP Dataproc)**: Self-managed Apache Zeppelin on Hadoop cluster (HDFS, YARN, Hive)
- Both environments use **PySpark DataFrames**, demonstrating code portability across platforms

### Retail Analysis (Databricks)
**Dataset**: 1M+ UK retail transactions (2009-2011)

**Analytics Performed**:
1. Invoice Amount Distribution (85th percentile outlier filtering)
2. Monthly Placed and Canceled Orders
3. Monthly Sales Trends and Growth (YoY with window functions)
4. Monthly Active Users (unique customers)
5. New vs Existing User Segmentation
6. RFM Customer Segmentation (Champions, Loyal, At Risk, Lost)

**Key Techniques**: Data cleaning (excluded non-product codes), aggregations, window functions (`F.lag()`, `F.lead()`), time-series analysis, customer cohort analysis

**Notebook**: `retail_data_wrangling_pyspark.ipynb`

### Economic Indicators Analysis (Zeppelin)
**Dataset**: World Development Indicators (Parquet in HDFS/Hive)

**Analytics Performed**:
1. GDP Growth Time Series (country-specific trends)
2. Multi-Country Comparisons (distributed sorting/partitioning)
3. Maximum GDP Identification (aggregations with self-joins)

**Key Techniques**: Hive table integration (`spark.table()`), distributed processing, complex joins, SQL-to-PySpark translation

**Notebook**: `Spark Dataframe - WDI Data Analytics.zpln`

### Technology Stack
- **Language**: Python 3.x, PySpark
- **Platforms**: Azure Databricks, GCP Dataproc (Hadoop 3.x)
- **Storage**: HDFS (Parquet), Hive Metastore, Delta Lake
- **Notebooks**: Jupyter (.ipynb), Zeppelin (.zpln)

## Improvements
1. **Performance**: Broadcast joins, partition optimization, DataFrame caching
2. **Advanced Analytics**: ML models (churn prediction, recommendations), cohort retention, CLV
3. **Production**: Airflow scheduling, Delta Lake ACID transactions, data quality monitoring
4. **Integration**: Spark Structured Streaming, unified data lakehouse
5. **Visualization**: Tableau/Power BI dashboards, automated reporting

---
**This project demonstrates distributed data processing, cloud infrastructure management, and translating business requirements into scalable PySpark solutions.**