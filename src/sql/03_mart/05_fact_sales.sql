-- Creates the sales fact table.
-- One row represents one invoice line / one purchased track.

CREATE OR REPLACE TABLE workspace.d3_mart.fact_sales AS
SELECT
    -- Degenerate and dimension keys
    il.invoice_line_id,
    il.invoice_id,
    c.customer_id,
    d.date_key,
    t.track_id,
    e.employee_key,

    -- Measures
    il.quantity,
    CAST(il.unit_price AS DECIMAL(10, 2)) AS unit_price,
    CAST(il.quantity * il.unit_price AS DECIMAL(12, 2)) AS line_amount,

    -- Mart metadata
    CURRENT_DATE() AS mart_load_date,
    CURRENT_TIMESTAMP() AS mart_entry_date

FROM workspace.d3_clean.invoice_line_clean il

LEFT JOIN workspace.d3_clean.invoice_clean i
    ON il.invoice_id = i.invoice_id

LEFT JOIN workspace.d3_mart.dim_customer c
    ON i.customer_id = c.customer_id

LEFT JOIN workspace.d3_mart.dim_date d
    ON i.invoice_date = d.full_date

LEFT JOIN workspace.d3_mart.dim_track t
    ON il.track_id = t.track_id

LEFT JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id

WHERE il.invoice_line_id IS NOT NULL;