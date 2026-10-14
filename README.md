# NovaBank SQL Analytics

## Project Overview

NovaBank SQL Analytics is a banking transaction data analysis project built with PostgreSQL and pgAdmin. The project explores customer transaction activity, monthly trends, transaction categories, and data quality using SQL.

## Objectives

- Validate data quality and identify missing values and duplicate transaction IDs.
- Convert raw date fields into PostgreSQL date values.
- Analyze monthly transaction trends.
- Identify high-value customers using aggregation and ranking.
- Compare transaction activity by customer gender and location.
- Calculate key performance indicators (KPIs).

## Tools and Technologies

- PostgreSQL
- pgAdmin 4
- SQL
- Visual Studio Code
- Git and GitHub

## Dataset

The dataset contains banking transaction records with fields such as:

- Transaction ID
- Customer ID
- Customer date of birth
- Gender
- Customer location
- Account balance
- Transaction date and time
- Transaction amount in INR

The source CSV is not included in this repository because it contains customer and financial transaction fields. Place an authorized copy at `Dataset/bank_transactions.csv` locally before importing it into PostgreSQL. Do not commit customer or financial data.

## SQL Concepts Demonstrated

- SELECT, WHERE, ORDER BY
- GROUP BY and aggregate functions
- CASE WHEN
- Common Table Expressions (CTEs)
- Window functions: RANK(), ROW_NUMBER(), and SUM() OVER()
- Date functions: DATE_TRUNC()
- Data quality checks
- Index creation and query performance testing

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
└── README.md
```

## Key Business Questions

1. How does transaction activity change month by month?
2. Which customers have the highest recorded transaction amounts?
3. Which transaction categories contribute the most transaction value?
4. How does transaction activity vary by customer location and gender?
5. What are the overall transaction KPIs?
6. What data quality issues require further investigation?

## How to Run the Project

1. Install PostgreSQL and pgAdmin 4.
2. Create a database named `nova_bank_analytics`.
3. Import the original CSV into `public.bank_transactions`.
4. Run the data cleaning script to create `public.bank_transactions_clean`.
5. Run the remaining SQL scripts in numerical order.

**Important:** The cleaning script assumes dates use the `DD/MM/YY` format. Verify the source format before relying on the converted dates. The cleaning script drops and recreates the clean table, so use it carefully.

## Disclaimer

This project is for educational and portfolio purposes. The reported transaction value represents the sum of recorded transaction amounts, not bank revenue or profit. Findings should be interpreted in the context of the dataset and its limitations.