-- Create one reporting-ready row per distinct invoice date
CREATE OR REPLACE TABLE workspace.d3_mart.dim_date AS
SELECT DISTINCT
    -- Surrogate key: YYYYMMDD format for sorting, readability, and uniqueness
    CAST(DATE_FORMAT(invoice_date, 'yyyyMMdd') AS INT) AS date_key,

    -- The actual date
    invoice_date AS full_date,

    -- Breakdowns for analysis
    DATE_FORMAT(invoice_date, 'EEEE') AS day_of_week,   
    DATE_FORMAT(invoice_date, 'MMMM') AS month,         
    QUARTER(invoice_date) AS quarter,                   
    YEAR(invoice_date) AS year                       
FROM workspace.d3_clean.invoice_clean
WHERE invoice_date IS NOT NULL;

-- Confirm uniqueness of date_key
SELECT date_key, COUNT(*) AS cnt
FROM workspace.d3_mart.dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;

-- Record min, max, and row count
SELECT 
    MIN(full_date) AS min_date,
    MAX(full_date) AS max_date,
    COUNT(*) AS total_days
FROM workspace.d3_mart.dim_date;
