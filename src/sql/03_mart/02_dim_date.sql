-- Creates one reporting-ready row per invoice date.
CREATE TABLE IF NOT EXISTS workspace.d3_mart.dim_date AS
SELECT DISTINCT
    -- Surrogate key in YYYYMMDD format
    CAST(DATE_FORMAT(invoice_date, 'yyyyMMdd') AS INT) AS date_key,

    -- Actual date
    invoice_date AS full_date,

    -- Date attributes
    DATE_FORMAT(invoice_date, 'EEEE') AS day_of_week,
    DATE_FORMAT(invoice_date, 'MMMM') AS month_name,
    MONTH(invoice_date) AS month_number,
    QUARTER(invoice_date) AS quarter,
    YEAR(invoice_date) AS year,

    -- Mart metadata
    CURRENT_DATE() AS mart_load_date,
    CURRENT_TIMESTAMP() AS mart_entry_date

FROM workspace.d3_clean.invoice_clean
WHERE invoice_date IS NOT NULL;


