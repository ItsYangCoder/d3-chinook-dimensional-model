-- Loads the Customer source into the Raw layer.
-- This creates the table only if it does not already exist.

USE CATALOG workspace;
USE SCHEMA d3_raw;

CREATE TABLE IF NOT EXISTS workspace.d3_raw.customer_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Customer.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);