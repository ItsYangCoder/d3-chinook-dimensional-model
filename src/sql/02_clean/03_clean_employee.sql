-- Cleans and standardizes Employee information.
-- Source: workspace.d3_raw.employee_raw

USE CATALOG workspace;

USE SCHEMA d3_clean;


-- Create the Clean Employee table.

CREATE OR REPLACE TABLE workspace.d3_clean.employee_clean

USING DELTA

AS

SELECT

    EmployeeId AS employee_id,

    TRIM(FirstName) AS first_name,

    TRIM(LastName) AS last_name,

    CONCAT(
        TRIM(FirstName),
        ' ',
        TRIM(LastName)
    ) AS full_name,

    TRIM(Title) AS title,

    ReportsTo AS reports_to,

    BirthDate AS birth_date,

    HireDate AS hire_date,

    TRIM(Address) AS address,

    TRIM(City) AS city,

    TRIM(State) AS state,

    TRIM(Country) AS country,

    TRIM(PostalCode) AS postal_code,

    TRIM(Phone) AS phone,

    TRIM(Fax) AS fax,

    LOWER(TRIM(Email)) AS email

FROM workspace.d3_raw.employee_raw;


-- Check the number of cleaned employee records.

SELECT

    'employee_clean' AS table_name,

    COUNT(*) AS row_count

FROM workspace.d3_clean.employee_clean;


-- Preview the Clean Employee table.

SELECT *

FROM workspace.d3_clean.employee_clean

LIMIT 5;


-- Check for missing Employee IDs.

SELECT *

FROM workspace.d3_clean.employee_clean

WHERE employee_id IS NULL;


-- Check for duplicate Employee IDs.

SELECT

    employee_id,

    COUNT(*) AS record_count

FROM workspace.d3_clean.employee_clean

GROUP BY employee_id

HAVING COUNT(*) > 1;


-- Check employee names and titles.

SELECT

    employee_id,

    full_name,

    title

FROM workspace.d3_clean.employee_clean

ORDER BY employee_id;


-- Check employee reporting relationships.

SELECT

    employee_id,

    full_name,

    title,

    reports_to

FROM workspace.d3_clean.employee_clean

ORDER BY employee_id;


-- Compare Raw and Clean record counts.

SELECT

    (SELECT COUNT(*)
     FROM workspace.d3_raw.employee_raw) AS raw_count,

    (SELECT COUNT(*)
     FROM workspace.d3_clean.employee_clean) AS clean_count;