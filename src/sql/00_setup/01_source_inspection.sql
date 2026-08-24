-- Checks the shared Chinook source before creating Raw tables.

USE CATALOG workspace;


-- List the CSV files inside the shared Volume.
LIST '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/';


-- Preview the Customer source.
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Customer.csv',
    format => 'csv',
    header => true,
    inferSchema => true
)
LIMIT 5;


-- Record the important source row counts.
SELECT
    'Customer' AS source_file,
    COUNT(*) AS row_count
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Customer.csv',
    format => 'csv',
    header => true,
    inferSchema => true
)

UNION ALL

SELECT
    'Employee',
    COUNT(*)
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Employee.csv',
    format => 'csv',
    header => true,
    inferSchema => true
)

UNION ALL

SELECT
    'Invoice',
    COUNT(*)
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Invoice.csv',
    format => 'csv',
    header => true,
    inferSchema => true
)

UNION ALL

SELECT
    'InvoiceLine',
    COUNT(*)
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/InvoiceLine.csv',
    format => 'csv',
    header => true,
    inferSchema => true
)

ORDER BY source_file;