# Chinook Sales Data Warehouse

A dimensional data warehouse project built from the Chinook dataset using Databricks SQL. The project transforms source CSV files into Raw, Clean, and Mart layers to support sales analysis.

## Project Objective

To build a reusable dimensional model that supports sales reporting and analysis, including revenue, customer, track, genre, and time-based insights.

## Tools Used

- Databricks SQL
- Unity Catalog
- GitHub
- Draw.io
- Tableau
- Databricks Jobs

## Data Pipeline

The project follows a Medallion Architecture approach:

- **Raw Layer** – stores the source Chinook CSV data with minimal changes.
- **Clean Layer** – standardizes column names, data types, and data quality rules.
- **Mart Layer** – contains the dimensional model used for analysis.

## Dimensional Model

![Chinook Star Schema](./src/docs/images/chinook_star_schema.png)

The Mart layer follows a star schema.

- **Fact table:** `fact_sales`
  - Grain: one row represents one track purchased as part of an invoice line.
  - Measures: quantity, unit price, and line amount.

- **Dimensions:**
  - `dim_customer`
  - `dim_date`
  - `dim_track`
  - `dim_employee`

## Repository Structure

```text
.
├── src/
│   ├── docs/
│   │   └── image/
│   │       └── chinook_star_schema.png
│   └── sql/
│       ├── 00_setup/
│       ├── 01_raw/
│       ├── 02_clean/
│       ├── 03_mart/
│       └── 04_analytics/
├── tests/
└── README.md
```

## How to Review the Project

1. Review `src/sql/00_setup/00_setup.sql` to create the required catalog and schemas.

2. Review the source inspection file in `src/sql/00_setup/01_source_inspection.py` to check the Chinook CSV source files.

3. Run the SQL scripts in `src/sql/01_raw/` to create the Raw layer tables.

4. Run the SQL scripts in `src/sql/02_clean/` to clean and standardize the source data.

5. Run the Mart scripts in this order:

   - `src/sql/03_mart/01_dim_customer.sql`
   - `src/sql/03_mart/02_dim_date.sql`
   - `src/sql/03_mart/03_dim_employee.sql`
   - `src/sql/03_mart/04_dim_track.sql`
   - `src/sql/03_mart/05_fact_sales.sql`

6. Review the validation queries in the `tests/` folder.

7. Review the business analysis queries in `src/sql/04_analytics/`.

## Data Quality

Data quality checks were included to validate:

- Missing primary keys
- Duplicate records
- Invalid numeric values
- Invalid foreign-key relationships
- Record-count reconciliation between layers

## Orchestration

The pipeline is orchestrated using Databricks Jobs to run the Raw, Clean, Mart, validation, and analytics scripts in sequence.

## Notes

This project was created for educational purposes using the Chinook sample dataset.