-- Loads the Employee source file into the Raw layer.
-- The existing Raw table is not overwritten.

USE CATALOG workspace;
USE SCHEMA d3_raw;


-- Creates the Raw Employee table only when it does not yet exist.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.employee_raw
USING DELTA
AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Employee.csv',
    format => 'csv',
    header => true,
    inferSchema => true
);