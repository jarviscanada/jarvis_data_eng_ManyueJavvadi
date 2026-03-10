# Azure Databricks Data Engineering — Fraud Analytics & Market Intelligence

## Introduction

This project delivers two data pipelines built on Azure Databricks for a fintech client with two distinct analytical needs.

The first pipeline supports the client's fraud analytics team. Their analysts were working off stale CSV exports from an operational SQL database with no reliable ingestion process. Data quality was inconsistent and analysts spent more time cleaning data than detecting fraud patterns. The goal was to build a governed, production-grade pipeline that ingests raw transaction data, cleans and enriches it, and delivers a live fraud analytics dashboard the team can use daily.

The second pipeline supports the client's risk team, who needed visibility into daily market movements for four equities they hold exposure to. The goal was to ingest live stock data automatically each morning, compute price and volume trend metrics, and refresh a dashboard before markets open — with no manual intervention.

Both pipelines are built on **Medallion Architecture** (Bronze → Silver → Gold), chosen for its simplicity, maintainability, and suitability for teams transitioning from traditional data workflows to modern cloud-native pipelines. It provides clear data quality boundaries at each layer, makes issues easy to isolate and debug, and supports both batch and streaming workloads.

---

## Part 1 — ETL Pipeline: Fraud Analytics

### Architecture

```
Azure SQL DB ──────────────────────────────┐
ADLS Gen2 (labdata container) ─────────────┼──► Bronze Layer ──► Silver Layer ──► Gold Layer ──► Dashboard
                                           │
Azure Data Factory (attempted, documented) ┘
```

**Azure Resources**

| Resource | Name |
|---|---|
| Resource Group | jarvis-etl-rg |
| Storage Account (ADLS Gen2) | jarvisetlstorage |
| Azure SQL Database | jarvis-etl-sqldb |
| Databricks Workspace | jarvis-etl-dbw (Premium) |
| Azure Data Factory | jarvis-etl-adf |
| Unity Catalog | jarvis_etl |

### Data Sources

| File | Source | Ingestion Method |
|---|---|---|
| transactions_data.csv | ADLS Gen2 | External Location (CSV, 1.17GB) |
| cards_data.csv | Azure SQL DB | JDBC |
| users_data.csv | ADLS Gen2 | External Location |
| mcc_codes.json | ADLS Gen2 | External Location (converted to JSONL) |
| train_fraud_labels.json | ADLS Gen2 | External Location (converted to JSONL) |

### Pipeline Layers

**Bronze** — Raw ingestion. Data is loaded as-is with no transformations. Schema is inferred. Tables written as managed Delta tables in `jarvis_etl.bronze`.

**Silver** — Cleaning and enrichment. The `amount` column containing currency symbols is parsed to `decimal(10,2)`. Income and debt columns in user data are similarly cleaned. Transactions are enriched by joining with `mcc_codes` (merchant category descriptions) and `fraud_labels` (fraud indicators). Tables written to `jarvis_etl.silver`.

**Gold** — Business aggregations answering 14 fraud analysis questions covering fraud trends by time, merchant, user behavior, and transaction value. Tables written to `jarvis_etl.gold`.

### Engineering Decisions & Blockers

**Lakeflow Connect** was initially attempted for ingesting `cards_data` from Azure SQL DB. This failed due to exhausted `Standard FS Family vCPUs` quota in the Azure for Students subscription — Lakeflow requires a dedicated gateway VM that could not be provisioned. The fallback was JDBC, which achieved the same result. The Lakeflow attempt is documented as a valid architectural option for production environments where quota is not constrained.

**Azure Data Factory** was configured with linked services and a notebook activity to ingest JSON files. This was blocked by a known Unity Catalog limitation with ADF's Delta Lake connector, which does not natively support three-level namespace (`catalog.schema.table`). The fallback was reading JSON files directly via External Location in the bronze notebook.

**train_fraud_labels.json** (148MB) was a single nested JSON object rather than newline-delimited JSON. Spark's JSON reader parallelizes reads by splitting files at line boundaries — a single-object file cannot be split, causing driver memory exhaustion at this file size. The file was converted to JSONL format locally, uploaded to ADLS, and read as a standard multi-partition Spark read.

### Job Orchestration

A Databricks Job chains the pipeline in sequence:

```
Bronze Notebook ──► Silver Notebook ──► Gold Notebook ──► Dashboard Refresh
```

### Dashboard

Built on Databricks AI/BI (Lakeview). Includes fraud trend analysis by month, day of week, hour of day, merchant category, and daily monetary losses. Symbol filter widget allows the fraud team to slice data interactively.

---

## Part 2 — DLT Pipeline: Market Intelligence

### Architecture

```
Alpha Vantage API (via RapidAPI)
        │
        ▼
Bronze (raw OHLCV) ──► Silver (cleaned, typed) ──► Gold (price & volume trends) ──► Dashboard
```

### Pipeline Design Decisions

| Consideration | Decision | Rationale |
|---|---|---|
| Streaming vs Materialized View | Materialized View | Daily triggered batch, not continuous stream |
| SCD Type | Append (Type 2 behavior) | History required for 7/30/90 day trend computation |
| Triggered vs Continuous | Triggered | API rate limit of 25 requests/day |
| Failure Handling | try/except per symbol | One failing ticker should not block others |

### Pipeline Layers

**Bronze** — Fetches `TIME_SERIES_DAILY` data from Alpha Vantage API for four symbols: `IBM`, `AAPL`, `MSFT`, `GOOGL`. Returns 100 days of OHLCV data per symbol. Raw data written to `jarvis_etl.dlt.bronze_stock_prices`.

**Silver** — Casts types, parses trade dates, filters null closes. Written to `jarvis_etl.dlt.silver_stock_prices`.

**Gold** — Two tables:
- `gold_price_trends` — daily close price with 7/30/90 day price change and percentage change using window functions
- `gold_volume_trends` — rolling average volume over 7/30/90 day windows

### Job Orchestration

A Databricks Job runs daily on a schedule:

```
ETL Pipeline Update ──► Dashboard Refresh
```

API credentials are stored securely in Databricks Secrets (`dlt-scope`) and never hardcoded in source files.

### Dashboard

Built on Databricks AI/BI (Lakeview). Displays stock price over time, 7-day price percentage change, and 7-day average volume for all four symbols. Symbol filter allows the risk team to isolate individual tickers.

---

## Repository Structure

```
├── etl/
│   ├── bronze.py          # Raw ingestion from SQL DB and ADLS
│   ├── silver.py          # Cleaning, type casting, enrichment
│   ├── gold.py            # 14 fraud analysis aggregations
│   └── adf_ingestion.py   # ADF-triggered notebook (documented attempt)
├── dlt/
│   ├── transformations/
│   │   ├── bronze.py      # API ingestion via Alpha Vantage
│   │   ├── silver.py      # Cleaning and typing
│   │   └── gold.py        # Price and volume trend computations
│   └── utilities/
│       └── utils.py       # API fetch helper
└── README.md
```

## Improvements

1. Parameterize the ticker list in the DLT pipeline so the risk team can add new symbols without modifying code
2. Add DLT Expectations (data quality constraints) to enforce schema and value ranges at each layer
3. Replace JDBC ingestion with Lakeflow Connect once vCPU quota constraints are resolved
4. Implement real-time fraud scoring using Databricks Structured Streaming on the transactions pipeline
5. Add alerting on the Databricks Job for pipeline failures using email or Slack notifications
