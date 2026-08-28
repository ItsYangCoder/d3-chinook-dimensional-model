-- Shows revenue by genre per customer country.

SELECT
    c.country,
    t.genre_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id

INNER JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

GROUP BY
    c.country,
    t.genre_name

ORDER BY
    c.country,
    revenue DESC;