-- Loads the original Employee CSV file into the shared Raw schema.
-- Business values are kept unchanged.

USE CATALOG workspace;

USE SCHEMA d3_raw;


-- Create the Raw Employee table.

CREATE OR REPLACE TABLE workspace.d3_raw.employee_raw

USING DELTA

AS

SELECT *

FROM read_files(

    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Employee.csv',

    format => 'csv',

    header => true,

    inferSchema => true

);


-- Check the number of records loaded.

SELECT

    'employee_raw' AS table_name,

    COUNT(*) AS row_count

FROM workspace.d3_raw.employee_raw;


-- Preview the Raw Employee table.

SELECT *

FROM workspace.d3_raw.employee_raw

LIMIT 5;


-- Validate that Employee IDs are unique.

SELECT

    EmployeeId,

    COUNT(*) AS record_count

FROM workspace.d3_raw.employee_raw

GROUP BY EmployeeId

HAVING COUNT(*) > 1;


-- Check for missing Employee IDs.

SELECT *

FROM workspace.d3_raw.employee_raw

WHERE EmployeeId IS NULL;


-- Check employee reporting relationships.

SELECT

    EmployeeId,

    FirstName,

    LastName,

    Title,

    ReportsTo

FROM workspace.d3_raw.employee_raw

ORDER BY EmployeeId;


-- Validate that ReportsTo points to a valid Employee ID.

SELECT

    e.EmployeeId,

    CONCAT(e.FirstName, ' ', e.LastName) AS employee_name,

    e.ReportsTo,

    CONCAT(m.FirstName, ' ', m.LastName) AS manager_name

FROM workspace.d3_raw.employee_raw e

LEFT JOIN workspace.d3_raw.employee_raw m

    ON e.ReportsTo = m.EmployeeId

ORDER BY e.EmployeeId;


-- Check for invalid reporting relationships.
-- Employees with NULL ReportsTo are allowed because they may be top-level managers.

SELECT

    e.EmployeeId,

    e.FirstName,

    e.LastName,

    e.ReportsTo

FROM workspace.d3_raw.employee_raw e

LEFT JOIN workspace.d3_raw.employee_raw m

    ON e.ReportsTo = m.EmployeeId

WHERE e.ReportsTo IS NOT NULL

    AND m.EmployeeId IS NULL;