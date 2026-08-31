# Design Decisions and Assumptions

This document records the key design decisions, assumptions, and data-quality treatments made during the Chinook Dimensional Model project.

For details about the dimensional model design and table relationships, refer to star_schema.md.

---

# 1. Star Schema Design

## Decision
A star schema was implemented in the Mart layer consisting of:

- fact_sales
- dim_customer
- dim_employee
- dim_track
- dim_date

## Reason

The source Chinook dataset is highly normalized and optimized for transaction processing rather than analytics. A star schema simplifies reporting by reducing joins and providing a business-friendly structure for analysis. The selected design supports all required business questions, including:

- Sales performance
- Customer spending behavior
- Track popularity
- Revenue trends
- Employee performance

The fact table grain was defined as:

> One row per invoice line (one purchased track on a specific invoice).

Additional schema details and relationship diagrams are documented in `star_schema.md`. 【1-b1aebe】【2-706de7】

---

# 2. Customer Name Standardization

## Decision

Customer names were trimmed and leading/trailing spaces removed during transformation into `dim_customer`.

## Reason

This standardization improves consistency across reporting and prevents duplicate-looking values caused by accidental whitespace.

## Impact

- Cleaner customer reporting
- Consistent grouping and filtering
- No loss of business information

---

# 3. Employee Name Standardization

## Decision

Employee name fields were trimmed and standardized during creation of `dim_employee`.

## Reason

Several fields can contain unnecessary whitespace from source data loads. Removing extra spaces creates consistent dimension values and improves report readability.

## Impact

- Cleaner employee reporting
- Consistent dimension records
- Improved data quality

---

# 4. Date Dimension Key

## Decision

A surrogate-style `date_key` was created in `dim_date` using the format:

`YYYYMMDD`

## Reason

Fact tables require a stable join key to connect sales transactions to calendar attributes.

The date key allows reporting by:

- Day
- Month
- Quarter
- Year

without repeatedly calculating date attributes during analysis.

## Impact

- Simplified joins
- Faster reporting queries
- Standard dimensional modeling approach

---

# 5. Track Unit Price Correction

## Issue Observed

During data validation, some `unit_price` values contained:

- Null values
- Text values caused by source-column shifting

These records were identified as data-quality issues rather than legitimate pricing values.

## Decision

Invalid `unit_price` values were replaced with:

`0.99`

## Reason

Validation showed that:

- 0.99 was the minimum valid track price present in the dataset.
- Using the minimum valid price was considered safer than introducing null values into downstream calculations.
- This approach prevented failures in revenue calculations, aggregations, and analytics queries.

## Impact

- Revenue calculations remain executable.
- Fact table records remain usable.
- A documented assumption is retained for transparency.

## Limitation

Actual prices for affected records are unknown. The replacement value should be treated as a business assumption rather than a confirmed source value.

---

# 6. Medallion Architecture

## Decision

The project follows a layered Medallion Architecture:

### Raw Layer
Stores source CSV files with minimal transformation.

### Clean Layer
Applies data cleaning, standardization, type corrections, and validation.

### Mart Layer
Creates analytics-ready dimension and fact tables for reporting.

## Reason

Separating ingestion, cleansing, and reporting logic improves maintainability and allows issues to be isolated within a specific stage of the pipeline. 【1-b1aebe】【3-699059】

---

# 7. Validation-First Approach

## Decision

Validation checks were developed separately from transformation logic.

## Reason

Keeping validation queries independent from ETL scripts makes it easier to:

- Verify data quality
- Troubleshoot issues
- Confirm expected row counts
- Test reruns safely

## Examples

Validation focused on:

- Duplicate detection
- Missing keys
- Row count verification
- Invalid values
- Fact-to-dimension relationships

---

# 8. Business-Friendly Dimensions

## Decision

Dimension tables were designed to contain descriptive attributes needed for reporting rather than storing only technical identifiers.

## Reason

This reduces the need for analysts to repeatedly join back to source tables and makes reporting more intuitive.

Examples include:

- Customer names
- Employee names
- Track information
- Calendar attributes

---

# Known Assumptions

| Area | Assumption |
|--------|--------|
| Track Pricing | Invalid or shifted prices were replaced with 0.99 |
| Customer Names | Extra whitespace was removed |
| Employee Names | Extra whitespace was removed |
| Date Reporting | Date key uses YYYYMMDD format |
| Sales Grain | One row per invoice line |

---

# Future Improvements

Potential future enhancements include:

- Investigating original source records for invalid prices instead of applying a default value
- Implementing automated anomaly detection during ingestion
- Adding audit columns across all Mart tables
- Introducing slowly changing dimension strategies if business requirements expand
- Expanding the dimensional model with additional dimensions if new reporting requirements arise