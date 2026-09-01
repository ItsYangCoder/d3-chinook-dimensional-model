-- Creates the employee dimension table for reporting.
CREATE TABLE IF NOT EXISTS workspace.d3_mart.dim_employee
USING DELTA
AS
SELECT
    -- Surrogate-style key for joining to fact_sales
    employee_id AS employee_key,

    -- Employee attributes
    employee_id,
    full_name,
    title,
    city,
    country,

    -- Mart metadata
    CURRENT_DATE() AS mart_load_date,
    CURRENT_TIMESTAMP() AS mart_entry_date

FROM workspace.d3_clean.employee_clean
WHERE employee_id IS NOT NULL;
