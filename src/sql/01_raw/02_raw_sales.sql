-- Loads the Invoice and InvoiceLine source files into the Raw layer.
-- The existing Raw tables are not overwritten.

USE CATALOG workspace;
USE SCHEMA d3_raw;


-- Creates the Raw Invoice table only when it does not yet exist.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.invoice_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Invoice.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);


-- Creates the Raw InvoiceLine table only when it does not yet exist.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.invoice_line_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/InvoiceLine.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);