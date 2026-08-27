# Sales Dimensional Model

## Overview

The Chinook Sales Mart is designed around **fact_sales**, where one row represents one purchased Track on one invoice line.

The implemented model is star-oriented:

- **fact_sales** connects directly to **dim_customer**, **dim_date**, and **dim_track**.
- **dim_employee** is connected through **dim_customer.support_rep_id**.
- The Employee relationship is therefore a small snowflake extension, not a direct Fact relationship.

This document describes the model as implemented in the reviewed SQL on **main**.

## Model diagram

~~~mermaid
erDiagram
    DIM_CUSTOMER ||--o{ FACT_SALES : customer_id
    DIM_DATE ||--o{ FACT_SALES : date_key
    DIM_TRACK ||--o{ FACT_SALES : track_id
    DIM_EMPLOYEE ||--o{ DIM_CUSTOMER : support_rep_id

    FACT_SALES {
        bigint invoice_line_id PK
        bigint invoice_id
        int customer_id FK
        int date_key FK
        bigint track_id FK
        int quantity
        decimal unit_price
        decimal line_amount
    }

    DIM_CUSTOMER {
        int customer_id PK
        string full_name
        string email_address
        string city
        string country
        int support_rep_id FK
    }

    DIM_DATE {
        int date_key PK
        date full_date
        string day_of_week
        string month
        int quarter
        int year
    }

    DIM_TRACK {
        bigint track_id PK
        string track_name
        bigint album_id
        string album_title
        bigint artist_id
        string artist_name
        bigint genre_id
        string genre_name
        bigint media_type_id
        string media_type_name
    }

    DIM_EMPLOYEE {
        int employee_key PK
        int employee_id
        string full_name
        string title
        string city
        string country
    }
~~~

## Fact grain

**One row in fact_sales represents one invoice line.**

The business grain is defined by **invoice_line_id**. If one invoice contains five purchased Tracks, it produces five Fact rows.

Expected baseline:

- 2,240 Fact rows
- 2,240 unique invoice-line IDs
- zero duplicate invoice-line IDs

The grain must be confirmed before any measure is aggregated.

## Fact table

### fact_sales

Source files:

- **src/sql/03_mart/05_fact_sales.sql**
- **workspace.d3_clean.invoice_line_clean**
- **workspace.d3_clean.invoice_clean**

| Column | Role | Description |
|---|---|---|
| invoice_line_id | Primary identifier | Unique purchased Track line |
| invoice_id | Degenerate dimension | Invoice identifier retained without a separate invoice dimension |
| customer_id | Foreign key | Joins to dim_customer |
| date_key | Foreign key | Joins to dim_date |
| track_id | Foreign key | Joins to dim_track |
| quantity | Additive measure | Number of purchased units |
| unit_price | Unit measure | Source price for the invoice line |
| line_amount | Additive measure | quantity multiplied by unit_price |

Core calculation:

~~~text
line_amount = quantity × unit_price
~~~

**Invoice totals are not stored on every Fact row.** Repeating an invoice-header total across invoice lines would cause double counting. Invoice totals are used only for reconciliation.

## Dimensions

### dim_customer

Grain: one row per customer  
Primary key: **customer_id**  
Validated rows: **59**

Main attributes:

- customer name and contact information
- city, country, and postal code
- support representative identifier

The **support_rep_id** field links the Customer dimension to **dim_employee.employee_id**.

### dim_date

Grain: one row per distinct invoice date  
Primary key: **date_key**  
Validated rows: **354**

The Date key uses **YYYYMMDD** integer format. Attributes support weekday, month, quarter, and year analysis.

Validated date range:

~~~text
2021-01-01 to 2025-12-22
~~~

### dim_track

Grain: one row per Track  
Primary key: **track_id**  
Validated rows: **3,503**

The dimension contains:

- Track name and composer
- duration and file size
- catalog unit price
- Album ID and title
- Artist ID and name
- Genre ID and name
- Media Type ID and name

The Track dimension is denormalized for reporting so analytics do not need to repeatedly join the Raw Album, Artist, Genre, and Media Type tables.

### dim_employee

Grain: one row per employee  
Primary key: **employee_key**  
Business key: **employee_id**  
Validated rows: **8**

Employee sales-support performance is reached through:

~~~text
fact_sales.customer_id
    → dim_customer.customer_id
    → dim_customer.support_rep_id
    → dim_employee.employee_id
~~~

This relationship is indirect in the current implementation.

## Relationship contracts

| From | To | Join condition | Expected result |
|---|---|---|---|
| fact_sales | dim_customer | fact_sales.customer_id = dim_customer.customer_id | Every Fact row resolves |
| fact_sales | dim_date | fact_sales.date_key = dim_date.date_key | Every Fact row resolves |
| fact_sales | dim_track | fact_sales.track_id = dim_track.track_id | Every Fact row resolves |
| dim_customer | dim_employee | dim_customer.support_rep_id = dim_employee.employee_id | Every assigned support representative resolves |

The Fact table uses **LEFT JOIN** operations during creation to preserve invoice-line grain and expose unresolved dimension keys during validation.

## Measures and aggregation

| Measure | Aggregation | Notes |
|---|---|---|
| quantity | SUM | Total units sold |
| line_amount | SUM | Total revenue |
| unit_price | AVG, MIN, or MAX | Do not SUM unit prices |
| invoice_line_id | COUNT | Purchased line count |
| invoice_id | COUNT DISTINCT | Invoice count |

Example business metrics:

- Revenue: **SUM(line_amount)**
- Units sold: **SUM(quantity)**
- Invoice count: **COUNT(DISTINCT invoice_id)**
- Average line value: **AVG(line_amount)**

## Validation controls

The Mart is accepted only when the following checks pass:

| Validation | Expected result |
|---|---:|
| fact_sales rows | 2,240 |
| Unique invoice_line_id values | 2,240 |
| Missing Customer keys | 0 |
| Missing Date keys | 0 |
| Missing Track keys | 0 |
| Duplicate invoice_line_id values | 0 |
| Invalid quantities | 0 |
| Invalid unit prices | 0 |
| Invalid line amounts | 0 |
| Invoice-total reconciliation differences | 0 |
| dim_customer rows | 59 |
| dim_date rows | 354 |
| dim_track rows | 3,503 |
| dim_employee rows | 8 |

## Design decisions

### InvoiceLine grain

The model uses invoice-line grain because Track, quantity, and unit price exist at that level. Invoice-header grain would remove the detail needed for Track, Album, Artist, and Genre analysis.

### Degenerate Invoice identifier

**invoice_id** remains in the Fact table as a degenerate dimension. A separate Invoice dimension is unnecessary because the current analytics do not require additional invoice-header descriptors as a dimension.

### Denormalized Track attributes

Album, Artist, Genre, and Media Type descriptions are stored in **dim_track**. This reduces repeated joins and provides a reporting-ready Track dimension.

### Employee relationship

Employee is currently connected through Customer because the support representative is assigned to the Customer. If a future requirement needs a direct employee key on every Fact row, that must be implemented and validated as a separate model change.

### Source-value preservation

Valid source prices, including **0.99** and **1.99**, are preserved. The model does not use a hardcoded fallback without documented evidence.

## Supported analysis

The model supports:

- revenue and units sold by Track
- Genre, Album, and Artist performance
- customer and country sales
- monthly, quarterly, and yearly sales trends
- invoice counts and average line values
- support-representative performance through the Customer relationship
- Track popularity by Genre or Playlist

## Known limitations

- Employee is not a direct foreign key in fact_sales.
- The model uses source business keys rather than generated warehouse surrogate keys for most dimensions.
- Slowly changing dimension history is not implemented.
- Data freshness monitoring and automated orchestration are not implemented.
- The current validation baseline applies to the provided Chinook source version.

These limitations are documented to prevent the model from being presented as more mature than its current implementation.
