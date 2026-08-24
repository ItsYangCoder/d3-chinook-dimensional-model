-- Loads the original sales CSV files into the shared Raw schema.
-- Business values are kept unchanged.

USE CATALOG workspace;
USE SCHEMA d3_raw;


-- Create the Raw Invoice table.
CREATE OR REPLACE TABLE workspace.d3_raw.invoice_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Invoice.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);


-- Create the Raw InvoiceLine table.
CREATE OR REPLACE TABLE workspace.d3_raw.invoice_line_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/InvoiceLine.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);


-- Check the number of records loaded.
SELECT
    'invoice_raw' AS table_name,
    COUNT(*) AS row_count
FROM workspace.d3_raw.invoice_raw

UNION ALL

SELECT
    'invoice_line_raw' AS table_name,
    COUNT(*) AS row_count
FROM workspace.d3_raw.invoice_line_raw;


-- Preview the Raw tables.
SELECT *
FROM workspace.d3_raw.invoice_raw
LIMIT 5;

SELECT *
FROM workspace.d3_raw.invoice_line_raw
LIMIT 5;