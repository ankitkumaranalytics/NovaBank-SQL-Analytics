
# NovaBank SQL Analytics

## Project Overview

NovaBank SQL Analytics is a banking transaction data analysis project built using PostgreSQL and SQL. The project demonstrates data quality validation, data cleaning, business analysis, customer analytics, banking KPIs, advanced SQL techniques, and RFM-based customer segmentation.

## Objectives

- Validate banking transaction data quality.
- Clean and prepare transaction data for analysis.
- Analyze transaction trends and customer behavior.
- Calculate banking KPIs and monthly performance.
- Apply advanced SQL techniques using CTEs and window functions.
- Segment customers using Recency, Frequency, and Monetary (RFM) analysis.

## Technology Stack

- **Database:** PostgreSQL
- **SQL Environment:** pgAdmin 4
- **Code Editor:** Visual Studio Code
- **Version Control:** Git and GitHub
- **Dataset:** Banking transaction CSV

## Project Structure

```text
NovaBank-SQL-Analytics/
├── Dataset/
├── Sql/
│   ├── 01_data_quality_checks.sql
│   ├── 02_data_cleaning.sql
├── 03_business_analysis.sql
├── 04_customer_analysis.sql
├── 05_banking_kpis.sql
├── 06_advanced_sql_analysis.sql
├── 07_customer_rfm_analysis.sql
└── README.md
```

The source CSV is not included because it contains customer and financial transaction fields. Place an authorized copy at `Dataset/bank_transactions.csv` locally before importing it into PostgreSQL. Do not commit customer or financial data.

## SQL Analysis Modules

| File | Description |
|---|---|
| 01_data_quality_checks.sql | Missing values, duplicate records, and data validation |
| 02_data_cleaning.sql | Cleaning and preparing transaction data |
| 03_business_analysis.sql | Transaction trends and business performance |
| 04_customer_analysis.sql | Customer behavior and spending analysis |
| 05_banking_kpis.sql | Banking KPIs and monthly metrics |
| 06_advanced_sql_analysis.sql | Window functions, CTEs, rolling averages, growth, cohorts, and outliers |
| 07_customer_rfm_analysis.sql | RFM scoring, customer segmentation, and segment-level summaries |

## Database Setup

Create the project database in PostgreSQL:

```sql
CREATE DATABASE nova_bank_analytics;
```

Connect to `nova_bank_analytics` using pgAdmin 4.

Import `Dataset/bank_transactions.csv` into the raw table:

```text
public.bank_transactions
```

Run the SQL scripts in order, from `01_data_quality_checks.sql` through `07_customer_rfm_analysis.sql`, using the correct file paths and table names.

**Important:** Review the cleaning script before rerunning it, because it may drop and recreate the cleaned table.

The analysis scripts use the cleaned table:

```text
public.bank_transactions_clean
```

## Key SQL Concepts Demonstrated

- SELECT, WHERE, GROUP BY, and HAVING
- Aggregate functions and CASE expressions
- Joins and subqueries
- Common Table Expressions (CTEs)
- Window functions: LAG, LEAD, RANK, DENSE_RANK, and ROW_NUMBER
- Running totals and moving averages
- Month-over-month analysis
- Outlier detection using IQR
- Customer cohort and retention analysis
- RFM scoring and customer segmentation
- Indexing and query performance analysis

## Business Value

This project demonstrates how SQL can transform raw banking transaction data into structured insights about customer activity, transaction patterns, spending behavior, retention, and customer value.

## Author

**Ankit Kumar**

- GitHub: https://github.com/ankitkumaranalytics
- Project Repository: https://github.com/ankitkumaranalytics/NovaBank-SQL-Analytics

## Disclaimer

This is an educational portfolio project. The dataset and analysis are intended for demonstration and learning purposes and do not represent official banking reports.
