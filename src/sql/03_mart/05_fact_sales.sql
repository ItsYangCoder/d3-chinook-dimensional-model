-- Creates the Sales fact table.
-- One row represents one invoice line.

USE CATALOG workspace;
USE SCHEMA d3_mart;

CREATE OR REPLACE TABLE workspace.d3_mart.fact_sales AS
SELECT
    il.invoice_line_id,
    il.invoice_id,
    c.customer_id,
    d.date_key,
    t.track_id,
    il.quantity,
    CAST(il.unit_price AS DECIMAL(10, 2)) AS unit_price,
    CAST(il.quantity * il.unit_price AS DECIMAL(12, 2)) AS line_amount

FROM workspace.d3_clean.invoice_line_clean il

LEFT JOIN workspace.d3_clean.invoice_clean i
    ON il.invoice_id = i.invoice_id

LEFT JOIN workspace.d3_mart.dim_customer c
    ON i.customer_id = c.customer_id

LEFT JOIN workspace.d3_mart.dim_date d
    ON i.invoice_date = d.full_date

LEFT JOIN workspace.d3_mart.dim_track t
    ON il.track_id = t.track_id;

-- Checks the fact table row count and dimension keys.

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(DISTINCT invoice_line_id) AS unique_invoice_lines,

    SUM(CASE WHEN invoice_line_id IS NULL THEN 1 ELSE 0 END)
        AS missing_invoice_line_ids,

    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END)
        AS missing_invoice_ids,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_ids,

    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END)
        AS missing_date_keys,

    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END)
        AS missing_track_ids,

    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END)
        AS invalid_quantities,

    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END)
        AS invalid_unit_prices,

    SUM(CASE WHEN line_amount IS NULL OR line_amount <= 0 THEN 1 ELSE 0 END)
        AS invalid_line_amounts

FROM workspace.d3_mart.fact_sales;

-- Checks for duplicate invoice line IDs.

SELECT
    invoice_line_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_mart.fact_sales
GROUP BY invoice_line_id
HAVING COUNT(*) > 1;

-- Compares invoice totals with the sum of line amounts.

SELECT
    COUNT(*) AS invoices_with_difference
FROM (
    SELECT
        f.invoice_id,
        SUM(f.line_amount) AS calculated_total,
        MAX(i.total) AS invoice_total
    FROM workspace.d3_mart.fact_sales f

    LEFT JOIN workspace.d3_clean.invoice_clean i
        ON f.invoice_id = i.invoice_id

    GROUP BY f.invoice_id

    HAVING ROUND(SUM(f.line_amount), 2)
        <> ROUND(MAX(i.total), 2)
);