-- Shows monthly sales trend based on invoice date.

SELECT
    d.year,
    d.month_number,
    d.month_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key

GROUP BY
    d.year,
    d.month_number,
    d.month_name

ORDER BY
    d.year,
    d.month_number;