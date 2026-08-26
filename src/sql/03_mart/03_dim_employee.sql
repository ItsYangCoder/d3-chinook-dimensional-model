-- Creates the Employee Dimension table for reporting.
-- Source: workspace.d3_clean.employee_clean

USE CATALOG workspace;

USE SCHEMA d3_mart;


-- Create the Employee Dimension table.

CREATE OR REPLACE TABLE workspace.d3_mart.dim_employee

USING DELTA

AS

SELECT

    employee_id AS employee_key,

    employee_id,

    full_name,

    title,

    city,

    country

FROM workspace.d3_clean.employee_clean;


-- Check the number of employees in the dimension.

SELECT

    COUNT(*) AS total_employees

FROM workspace.d3_mart.dim_employee;


-- Preview the Employee Dimension table.

SELECT *

FROM workspace.d3_mart.dim_employee

ORDER BY employee_id;


-- Check for missing Employee Keys.

SELECT *

FROM workspace.d3_mart.dim_employee

WHERE employee_key IS NULL;


-- Check for missing Employee IDs.

SELECT *

FROM workspace.d3_mart.dim_employee

WHERE employee_id IS NULL;


-- Check for duplicate Employee Keys.

SELECT

    employee_key,

    COUNT(*) AS record_count

FROM workspace.d3_mart.dim_employee

GROUP BY employee_key

HAVING COUNT(*) > 1;


-- Check for duplicate Employee IDs.

SELECT

    employee_id,

    COUNT(*) AS record_count

FROM workspace.d3_mart.dim_employee

GROUP BY employee_id

HAVING COUNT(*) > 1;


-- Compare Clean and Mart employee record counts.

SELECT

    (SELECT COUNT(*)
     FROM workspace.d3_clean.employee_clean) AS clean_count,

    (SELECT COUNT(*)
     FROM workspace.d3_mart.dim_employee) AS mart_count;


-- View employees that are Sales Support Agents.

SELECT

    employee_key,

    employee_id,

    full_name,

    title,

    city,

    country

FROM workspace.d3_mart.dim_employee

WHERE title = 'Sales Support Agent'

ORDER BY employee_id;