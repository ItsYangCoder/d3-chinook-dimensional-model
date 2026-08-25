# D3 Chinook Dimensional Model

A Group D3 data-engineering project that converts the normalized Chinook sales dataset into an analytics-ready dimensional model in Databricks.

> **Project status:** In development  
> Setup, source inspection, and Raw Sales have been completed. Clean, Mart, analytics, validation, dashboard, and presentation work are still being developed and reviewed.

## Project objective

The project demonstrates an end-to-end data workflow:

1. Inspect the shared Chinook CSV files.
2. Load the source data into Raw Delta tables.
3. Clean and standardize each data domain.
4. Build a star schema with facts and dimensions.
5. Answer business questions through reusable SQL.
6. Validate the results and present them in a dashboard.

## Architecture

| Layer | Databricks schema | Purpose |
|---|---|---|
| Source | Shared Unity Catalog Volume | Stores the original CSV files without modification |
| Raw | `workspace.d3_raw` | Holds source-aligned Delta tables |
| Clean | `workspace.d3_clean` | Holds cleaned and standardized data |
| Mart | `workspace.d3_mart` | Holds dimension and fact tables |
| Quality | `workspace.d3_quality` | Holds validation results or invalid records |

The intended processing flow is:

`Volume CSVs → Raw → Clean → Mart → Analytics → Dashboard`

## Source data

The Chinook CSV files are read from the shared Databricks Volume:

```text
/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/
```

The repository does **not** contain copies of the source CSV files. Users need access to the same Volume or must configure an authorized equivalent source path.

## Dimensional model

The proposed fact-table grain is:

> One row in `fact_sales` represents one track purchased as part of an invoice.

Planned Mart tables:

| Table | Purpose |
|---|---|
| `dim_customer` | Customer attributes used for segmentation and location analysis |
| `dim_date` | Calendar attributes used for time-based reporting |
| `dim_employee` | Employee and sales-support attributes |
| `dim_track` | Track, album, artist, genre, and media attributes |
| `fact_sales` | Invoice-line sales measures and dimension references |

The final column names and relationships will be confirmed against the implemented Clean and Mart tables.

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

- `src/notebooks/` contains interactive exploration and presentation notebooks.
- `src/sql/00_setup/` creates schemas and inspects the source.
- `src/sql/01_raw/` loads source-aligned Delta tables.
- `src/sql/02_clean/` cleans and standardizes each domain.
- `src/sql/03_mart/` creates dimensions and the sales fact table.
- `src/sql/04_analytics/` contains business-analysis queries.
- `tests/` contains source, Clean, Mart, and business-query checks.
- `docs/` contains modeling decisions, assumptions, the data dictionary, and presentation notes.
- `dashboard/` contains dashboard planning and final insights.

## Current progress

| Work item | Status |
|---|---|
| Repository structure | Complete |
| Shared Databricks schemas | Complete |
| Source inspection | Complete |
| Source-exploration notebook | Complete |
| Raw Invoice and InvoiceLine tables | Complete |
| Other Raw domain tables | In progress |
| Clean tables | In progress |
| Dimensions and `fact_sales` | Pending dependencies |
| Business analytics | Pending Mart |
| Validation and dashboard | In progress |

Completed Raw Sales outputs:

| Table | Verified rows |
|---|---:|
| `workspace.d3_raw.invoice_raw` | 412 |
| `workspace.d3_raw.invoice_line_raw` | 2,240 |

The source row counts matched the created Raw tables. Databricks also produced the technical `_rescued_data` column during file ingestion; inspected rows did not contain rescued values.

## Execution order

Run files according to their numbered folders:

1. `00_setup`
2. `01_raw`
3. `02_clean`
4. `03_mart`
5. `04_analytics`
6. `tests`
7. Dashboard and project-demo notebook

Do not run Mart files until their required Clean tables and dimensions are available.

## Databricks requirements

- Access to the project Databricks workspace
- `USE CATALOG` on `workspace`
- Required permissions on the D3 schemas
- `USE SCHEMA` on `workspace.bronze`
- `READ VOLUME` on `workspace.bronze.1st_volume`
- A running SQL warehouse or supported serverless compute

Example source-access check:

```sql
LIST '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/';
```

## Collaboration workflow

1. Pull the latest `main`.
2. Create a task-specific branch.
3. Edit only the assigned files.
4. Run and validate the SQL in Databricks.
5. Commit with a clear message.
6. Push the branch and open a pull request.
7. Review the changed files and results before merging.

Branches are personal working copies connected to the same GitHub repository. Team members should not share Databricks or GitHub credentials.

## Data privacy and security

- Original source files remain in the controlled Databricks Volume.
- CSV files, exports, screenshots containing sensitive information, and credentials must not be committed.
- Access keys, personal access tokens, secrets, and Databricks credentials must never appear in SQL, notebooks, documentation, issues, or pull requests.
- Access is granted through Unity Catalog and repository permissions using each member's own account.
- Follow least privilege: grant only the permissions needed for the assigned work.
- Do not expose personal workspace URLs, user folders, email addresses, or account identifiers in public documentation.
- Review notebook outputs and screenshots before sharing them outside the approved team workspace.
- If real personal or confidential data is introduced later, it must be classified and handled according to the organization’s data-governance policy.

## Business questions

The project is designed to support:

- Top revenue-generating genre per country
- Customer segmentation by spending tier
- Monthly sales trends
- Employee sales performance
- Track popularity
- Regional differences in customer behavior and pricing

## Validation approach

The project checks:

- Source-to-Raw row counts
- Duplicate and missing identifiers
- Missing table relationships
- Fact-table grain
- Foreign-key coverage
- Sales calculations using quantity and unit price
- Reconciliation between invoice totals and invoice-line sales
- Business-query output accuracy

## Notes

This repository is an educational project under active development. SQL outputs and documentation should be updated when implementation decisions are finalized.
