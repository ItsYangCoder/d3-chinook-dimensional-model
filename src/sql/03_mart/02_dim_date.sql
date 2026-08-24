-- Create one reporting-ready row per day in dim_date
CREATE OR REPLACE TABLE workspace.d3_mart.dim_date AS
SELECT DISTINCT
    -- Surrogate key: YYYYMMDD format for Sorting, readability and uniqueness
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

SELECT *
FROM workspace.d3_mart.dim_date;