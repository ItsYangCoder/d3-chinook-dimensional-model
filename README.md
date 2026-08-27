# D3 Chinook Sales Analytics

A Databricks SQL dimensional-modeling project that converts the normalized Chinook dataset into a governed, analytics-ready sales mart. The implementation follows a layered Raw → Clean → Mart → Analytics workflow, uses Unity Catalog for data organization, and applies validation gates before downstream models are accepted.

> **Delivery status:** Core pipeline complete; remaining team analytics and dashboard work in progress  
> **System type:** Educational, production-oriented implementation  
> **Delivery branch:** main is the reviewed integration baseline

## Business purpose

The project provides a reusable sales model for analyzing:

1. Revenue-generating genres by country
2. Customer spending segments
3. Monthly sales trends
4. Employee sales-support performance
5. Track popularity by genre or playlist
6. Regional customer and pricing differences

Business queries read from the Mart layer rather than directly from CSV files or Raw tables.

## Current delivery status

| Component | Status | Evidence |
|---|---|---|
| Project setup and source inspection | Complete | Shared schemas and source access validated |
| Customer pipeline | Complete | Raw, Clean, and dimension contain 59 validated customers |
| Employee pipeline | Complete | Raw, Clean, and dimension contain 8 validated employees |
| Sales pipeline | Complete | 412 invoices and 2,240 invoice lines reconciled |
| Date dimension | Complete | 354 unique dates from 2021-01-01 to 2025-12-22 |
| Music pipeline | Complete | 3,503 Track rows and relationships validated |
| Sales fact | Complete | 2,240 unique invoice-line facts with no unresolved keys |
| Genre revenue analysis | Complete | Query and Databricks visualization validated |
| Remaining analytics and dashboard | In progress | Final team outputs are being completed |

## Architecture

~~~mermaid
flowchart TD
    A["Unity Catalog Volume"] --> B["Raw Delta tables"]
    B --> C["Clean standardized tables"]
    C --> D["Dimensions and fact_sales"]
    D --> E["Analytics SQL"]
    E --> F["Databricks dashboard"]
    B --> Q["Validation gates"]
    C --> Q
    D --> Q
~~~

| Layer | Location | Responsibility |
|---|---|---|
| Source | Unity Catalog Volume | Controlled read-only source files |
| Raw | **workspace.d3_raw** | Source-aligned Delta tables with minimal transformation |
| Clean | **workspace.d3_clean** | Standardized names, types, and validated business fields |
| Mart | **workspace.d3_mart** | Reporting-ready dimensions and central Sales fact |
| Quality | **workspace.d3_quality** | Persisted invalid records or reusable quality outputs |
| Analytics | SQL and dashboard | Business metrics, trends, rankings, and insights |

## Data lineage

~~~text
Chinook CSV files
    → workspace.d3_raw
    → workspace.d3_clean
    → workspace.d3_mart
    → analytics SQL
    → Databricks dashboard
~~~

The original CSV files remain unchanged. Downstream tables are reproducible from the authorized source path and reviewed SQL in **main**.

## Source contract

Source location:

~~~text
/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/
~~~

Rules:

- Source files are treated as read-only.
- CSV files and generated table data are not committed to Git.
- Raw tables preserve valid source business values.
- Cleaning logic must not invent or silently replace values.
- Enrichment or fallback logic requires a documented source and justification.
- Quoted fields, including Track names with commas, must be parsed using explicit CSV settings.

## Dimensional model

### Fact grain

One row in **fact_sales** represents one Track purchased on one invoice line.

The grain is based on **InvoiceLineId**, not the invoice header. An invoice containing five purchased Tracks produces five fact rows.

### Mart contracts

| Table | Grain | Primary identifier | Role |
|---|---|---|---|
| **dim_customer** | One row per customer | customer_id | Customer identity and location |
| **dim_date** | One row per invoice date | date_key | Calendar analysis |
| **dim_employee** | One row per employee | employee_id | Support-representative analysis |
| **dim_track** | One row per Track | track_id | Track, album, artist, genre, and media attributes |
| **fact_sales** | One row per invoice line | invoice_line_id | Quantity, unit price, and line-level revenue |

Core measure:

~~~text
line_amount = quantity × unit_price
~~~

**fact_sales** contains Customer, Date, and Track keys. Employee performance is resolved through the customer's support representative relationship.

## Verified data baselines

These values are validation controls, not row-level business data.

| Domain | Validation | Expected result |
|---|---|---:|
| Invoice | Raw and Clean rows | 412 |
| InvoiceLine | Raw and Clean rows | 2,240 |
| Clean Sales | One row per invoice line | 2,240 |
| Customer | Raw, Clean, and dimension rows | 59 |
| Employee | Raw, Clean, and dimension rows | 8 |
| Date | Unique dates and date keys | 354 |
| Date | Source range | 2021-01-01 to 2025-12-22 |
| Track source | Rows and unique Track IDs | 3,503 |
| Track source | Valid UnitPrice range | 0.99 to 1.99 |
| Track dimension | Rows and unique Track IDs | 3,503 |
| Track dimension | Missing descriptive relationships | 0 |
| Sales fact | Rows and unique InvoiceLine IDs | 2,240 |
| Sales fact | Missing Customer, Date, and Track keys | 0 |
| Sales fact | Duplicate InvoiceLine IDs | 0 |
| Sales reconciliation | Invoice-total differences | 0 |

A different result is treated as a failed validation until the source version, parsing configuration, filtering, joins, and duplicate keys are investigated.

## Repository structure

~~~text
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
└── docs/
~~~

| Location | Purpose |
|---|---|
| **src/notebooks/** | Source exploration and final demonstration |
| **src/sql/00_setup/** | Schema creation and source inspection |
| **src/sql/01_raw/** | Source-to-Delta ingestion |
| **src/sql/02_clean/** | Cleaning, standardization, and integration |
| **src/sql/03_mart/** | Dimensions and Sales fact |
| **src/sql/04_analytics/** | Business-facing analytical queries |
| **tests/** | Source, Clean, Mart, and analytics checks |
| **docs/** | Assumptions, data dictionary, model design, and presentation notes |

## Environment requirements

- Access to the shared Databricks workspace
- Supported SQL warehouse or serverless compute
- **USE CATALOG** on **workspace**
- Required privileges on **d3_raw**, **d3_clean**, **d3_mart**, and **d3_quality**
- **USE SCHEMA** on **workspace.bronze**
- **READ VOLUME** on **workspace.bronze.1st_volume**
- Repository access through the member's own GitHub account

Source-access check:

~~~sql
LIST '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/';
~~~

## Deployment and execution runbook

Run reviewed code from the latest **main** branch only.

1. Pull the latest **main** in the Databricks Git folder.
2. Run **src/sql/00_setup/**.
3. Run the required files in **src/sql/01_raw/**.
4. Run **tests/01_source_checks.sql**.
5. Run the required files in **src/sql/02_clean/**.
6. Run **tests/02_clean_checks.sql**.
7. Run the required files in **src/sql/03_mart/**.
8. Run **tests/03_mart_checks.sql**.
9. Run **src/sql/04_analytics/**.
10. Run **tests/04_business_query_checks.sql**.
11. Refresh the Databricks dashboard and demonstration notebook.

Do not run a downstream model when an upstream dependency is missing, unvalidated, or under review.

## Validation gates

| Gate | Pass condition |
|---|---|
| Source ingestion | Expected tables and row counts are present |
| Primary keys | Required identifiers are populated and unique at the defined grain |
| Foreign keys | Required dimension relationships resolve |
| Numeric values | Quantities, prices, and amounts are positive and castable |
| Track parsing | Quoted titles parse without shifting columns |
| Fact grain | 2,240 rows and 2,240 unique InvoiceLine IDs |
| Financial reconciliation | Aggregated line amounts equal invoice totals |
| Analytics | Queries read from the final Mart and return reviewed results |

A model is not accepted solely because its SQL executes. It must also pass the applicable validation gates.

## Failure handling

When validation fails:

1. Stop downstream execution.
2. Record the failing query and actual result.
3. Confirm the source path and source version.
4. Check CSV parsing, casting, filtering, join cardinality, and duplicate keys.
5. Correct the issue in a focused branch.
6. Rerun upstream and downstream validation.
7. Merge only after runtime evidence is reviewed.

Do not repair source issues by hardcoding business values without documented evidence and approval.

## Development and change management

1. Pull the latest **main**.
2. Create a focused **feature/**, **fix/**, **test/**, or **docs/** branch.
3. Change only files required for the assigned task.
4. Execute the SQL in the shared Databricks workspace.
5. Record expected and actual validation results.
6. Commit with a clear action-based message.
7. Push the branch and open a pull request into **main**.
8. Review changed files, dependencies, table names, and runtime evidence.
9. Merge only after checks pass.
10. Delete obsolete branches after the merged result is verified.

A Databricks Git-folder clone is a personal working copy of the GitHub repository, not a separate project or fork.

## Ownership model

- Domain tasks and reviewers are assigned through GitHub Issues.
- Pull requests provide the review and approval record.
- The author supplies runtime validation evidence.
- The reviewer checks scope, dependencies, naming, grain, and validation.
- **main** is the shared delivery baseline.
- Team members pull **main** before starting dependent work.

## Definition of done

A task is complete only when:

- SQL runs successfully in the shared workspace.
- Upstream dependencies are available and validated.
- Table and column names follow the agreed conventions.
- Expected and actual row counts are recorded.
- Key, null, relationship, range, and measure checks pass.
- No undocumented business-value replacement is introduced.
- Related documentation is updated.
- The pull request is reviewed and merged into **main**.
- Dependent members pull the updated **main**.

## Security and data handling

- Never commit source-data exports, credentials, secrets, tokens, or passwords.
- Never share another member's Databricks or GitHub account.
- Use Unity Catalog and repository permissions instead of distributing credentials.
- Apply least-privilege access.
- Keep original files in the controlled Volume.
- Review screenshots, notebooks, logs, and query outputs before sharing.
- Do not publish personal emails, workspace identifiers, or user-directory paths.
- Validation counts may be documented when approved; row-level personal data must not be exposed.
- Stop processing real confidential data until classification, retention, masking, and access controls are defined.

## Operational boundaries

This repository demonstrates production-oriented data-engineering practices in an educational environment. It does not currently provide:

- automated deployment across environments
- scheduled orchestration
- automated data freshness monitoring
- formal service-level objectives
- automated rollback
- full CI/CD enforcement

These controls are recommended before using the design for a production workload.

## Related documentation

- [Star-schema design](docs/star_schema.md)
- [Assumptions](docs/assumptions.md)
- [Data dictionary](docs/data_dictionary.md)
- [Team timeline](docs/team_timeline.md)
- [Presentation notes](docs/presentation_notes.md)

## Project note

**main** contains reviewed and integrated work. Feature branches and pull requests are work in progress until their SQL has been executed, validated, reviewed, and merged.
