# D3 Chinook Dimensional Model

Databricks SQL project that transforms the normalized Chinook dataset into an analytics-ready star schema using a controlled **Source → Raw → Clean → Mart → Analytics** workflow.

> **Delivery status:** Active development  
> **Status date:** August 26, 2026 (PHT)  
> The repository structure, source exploration, project setup, and Raw Sales load are merged into `main`. Additional domain work exists on feature branches and must pass review before it becomes part of the integrated pipeline.

## Overview

The project is designed to demonstrate a small but complete data-engineering workflow:

- preserve the original CSV source;
- create source-aligned Delta tables;
- clean and standardize business data;
- build reusable facts and dimensions;
- validate row counts, keys, relationships, and measures;
- answer business questions through SQL and dashboards;
- manage team changes through branches and pull requests.

## Architecture

| Stage | Storage | Responsibility |
|---|---|---|
| Source | Unity Catalog Volume | Original Chinook CSV files; read-only for project members |
| Raw | `workspace.d3_raw` | Source-aligned Delta tables with minimal transformation |
| Clean | `workspace.d3_clean` | Standardized columns, data types, and validated relationships |
| Mart | `workspace.d3_mart` | Reporting-ready dimensions and `fact_sales` |
| Quality | `workspace.d3_quality` | Invalid records and reusable validation outputs |
| Analytics | SQL queries and dashboard | Business questions, trends, and final insights |

```text
Unity Catalog Volume
        ↓
      Raw
        ↓
      Clean
        ↓
Dimensions + fact_sales
        ↓
Analytics + validation + dashboard
```

## Source contract

The shared source is located at:

```text
/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/
```

Important rules:

- The repository does not store copies of the CSV files.
- Source files are not edited, renamed, or deleted by the pipeline.
- Raw tables are reproducible from the authorized Volume.
- A different environment must provide an equivalent authorized source and update the path through its own configuration process.

## Dimensional design

### Fact grain

One row in `fact_sales` represents **one track purchased on one invoice line**.

This grain is based on `InvoiceLineId`, not on the invoice header. It prevents invoice totals from being duplicated when an invoice contains multiple tracks.

### Planned star schema

| Table | Grain | Main use |
|---|---|---|
| `dim_customer` | One row per customer | Customer and geographic analysis |
| `dim_date` | One row per invoice date | Monthly, quarterly, and yearly trends |
| `dim_employee` | One row per employee | Sales-support performance |
| `dim_track` | One row per track | Track, album, artist, genre, and media analysis |
| `fact_sales` | One row per invoice line | Quantity, unit price, and sales amount |

Expected fact measure:

```text
sales_amount = quantity × unit_price
```

The final fact SQL must reconcile invoice-line sales with invoice totals before it is accepted.

## Repository structure

```text
d3-chinook-dimensional-model/
├── README.md
├── src/
│   ├── notebooks/
│   │   ├── 00_source_exploration.ipynb
│   │   └── 99_project_demo.ipynb
│   └── sql/
│       ├── 00_setup/
│       ├── 01_raw/
│       ├── 02_clean/
│       ├── 03_mart/
│       └── 04_analytics/
├── tests/
├── docs/
└── dashboard/
```

| Location | Purpose |
|---|---|
| `src/notebooks/` | Interactive source exploration and final demonstration |
| `src/sql/00_setup/` | Schema creation and repeatable source inspection |
| `src/sql/01_raw/` | Source-to-Delta ingestion |
| `src/sql/02_clean/` | Cleaning, standardization, and integration |
| `src/sql/03_mart/` | Dimensions and central sales fact |
| `src/sql/04_analytics/` | Business-facing analytical queries |
| `tests/` | Source, Clean, Mart, and business-query validation |
| `docs/` | Design decisions, assumptions, schema, and data dictionary |
| `dashboard/` | Dashboard plan and final insights |

## Delivery status

The status below reflects the repository audit, not only verbal progress reports.

| Component | Repository state | Review status |
|---|---|---|
| Project scaffolding | Merged into `main` | Complete |
| Source-exploration notebook | Merged into `main` | Complete |
| Setup and source inspection | Merged into `main` | Complete |
| Raw Invoice and InvoiceLine | Merged into `main` | Complete |
| Raw Customer | Code present on feature branch | PR/review required |
| Clean Customer | Code present on feature branch | PR/review required |
| Dim Customer | Code present on feature branch | PR/review required |
| Clean Sales | Code present on feature branch | Integration review required |
| Dim Date | Code present on feature branch | Depends on Clean Sales |
| Raw Music | Feature branch currently contains a placeholder | Implementation required |
| Clean Music | Code present on feature branch | Requires Raw Music and naming review |
| Dim Track | Code present on feature branch | Requires qualified table names and integration review |
| Raw/Clean/Dim Employee | Placeholder files on `main` | Implementation required |
| Fact Sales | Feature branch currently contains a placeholder | Blocked by Clean and dimensions |
| Monthly Sales Trend | Code present on feature branch | Must be updated to use final `fact_sales` |
| Other analytics | Placeholder or not yet integrated | Implementation required |
| Source and Clean tests | Code present on test branches | PR/review required |
| Mart and business tests | Placeholder files | Implementation required |
| Modeling documentation | Draft content on documentation branch | Technical review required |
| Dashboard outputs | Not yet integrated | Pending Mart and analytics |

### Verified merged results

| Table | Source | Verified rows |
|---|---|---:|
| `workspace.d3_raw.invoice_raw` | `Invoice.csv` | 412 |
| `workspace.d3_raw.invoice_line_raw` | `InvoiceLine.csv` | 2,240 |

Databricks created the technical `_rescued_data` column during ingestion. The inspected records contained no rescued values. This column should be checked during Raw validation and excluded from downstream business models unless needed for investigation.

## Known integration checks

The following must be resolved before the end-to-end pipeline is declared complete:

- Use fully qualified table names such as `workspace.d3_clean.table_name`.
- Agree on one naming convention, particularly `invoice_line_clean` versus `invoiceline_clean`.
- Complete Raw Music before executing Clean Music and `dim_track`.
- Review any fallback values used during music-data repair and document their business justification.
- Complete the employee domain before creating employee-related fact relationships or analysis.
- Update temporary analytics queries to use the final Mart tables.
- Confirm that all foreign keys in `fact_sales` resolve to the intended dimensions.
- Reconcile `SUM(quantity * unit_price)` against source invoice totals.
- Merge only tested changes into `main`.

## Execution order

Execute only code that has been reviewed and merged into `main`.

1. `src/sql/00_setup/`
2. `src/sql/01_raw/`
3. `tests/01_source_checks.sql`
4. `src/sql/02_clean/`
5. `tests/02_clean_checks.sql`
6. `src/sql/03_mart/`
7. `tests/03_mart_checks.sql`
8. `src/sql/04_analytics/`
9. `tests/04_business_query_checks.sql`
10. Dashboard and project-demo notebook

Do not run a downstream file when its upstream tables are missing or still under review.

## Environment requirements

- Membership in the correct shared Databricks workspace
- A SQL warehouse or supported serverless compute
- `USE CATALOG` on `workspace`
- Required privileges on `d3_raw`, `d3_clean`, `d3_mart`, and `d3_quality`
- `USE SCHEMA` on `workspace.bronze`
- `READ VOLUME` on `workspace.bronze.1st_volume`
- Access to this GitHub repository using the member's own account

Source-access check:

```sql
LIST '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/';
```

Raw Sales verification:

```sql
SELECT 'invoice_raw' AS table_name, COUNT(*) AS row_count
FROM workspace.d3_raw.invoice_raw

UNION ALL

SELECT 'invoice_line_raw', COUNT(*)
FROM workspace.d3_raw.invoice_line_raw;
```

Expected output: 412 invoice rows and 2,240 invoice-line rows.

## Development workflow

1. Switch to `main` and pull the latest changes.
2. Create a focused branch for one task.
3. Change only the assigned files.
4. Execute the SQL in the shared Databricks workspace.
5. Record row counts and validation results.
6. Commit with a clear, action-based message.
7. Push and open a pull request into `main`.
8. Review dependencies, changed files, and query results.
9. Merge only after the branch is current and checks pass.
10. Pull the updated `main` before starting dependent work.

A Databricks Git-folder clone is a working copy of the same GitHub repository. It is not a separate repository or a fork.

## Definition of done

A task is complete only when:

- the SQL runs successfully in the shared workspace;
- upstream dependencies are available;
- row counts and key checks are recorded;
- table and column names follow the agreed convention;
- no unauthorized business-value changes were introduced;
- documentation reflects material transformations or assumptions;
- the pull request has been reviewed and merged;
- dependent members have pulled the updated `main`.

Creating a branch or writing SQL without validation and merge does not count as completed delivery.

## Data privacy and security

This educational repository follows the same minimum controls expected in a working data project:

- Never commit CSV exports, secrets, access keys, personal access tokens, passwords, or Databricks credentials.
- Never share another member's Databricks or GitHub account.
- Use Unity Catalog and repository permissions instead of distributing credentials.
- Grant only the minimum access required for assigned work.
- Keep the original source in the controlled Volume.
- Review screenshots and notebook outputs before sharing.
- Do not publish workspace URLs, user-directory paths, email addresses, or account identifiers.
- Do not place confidential data in issue descriptions, commit messages, pull requests, or logs.
- If real personal data is introduced, stop and apply the organization’s classification, retention, masking, and access-control policies before processing it.

## Business outputs

The completed Mart is expected to support:

- top revenue-generating genre per country;
- customer segmentation by spending tier;
- monthly sales trends;
- employee sales performance;
- track popularity by genre or playlist;
- regional customer and pricing differences.

## Project note

This repository is an educational team project under active development. The `main` branch is the delivery baseline; feature branches are work in progress until reviewed and merged.
