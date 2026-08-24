-- Creation of Raw Customer Table

CREATE OR REPLACE TABLE workspace.d3_raw.customer_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Customer.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);

-- Validation of Source Raw Count
SELECT 'Customer' AS source_file, COUNT(*) AS row_count
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Customer.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);

--Viewing the Raw Customer Table
SELECT *
FROM workspace.d3_raw.customer_raw;