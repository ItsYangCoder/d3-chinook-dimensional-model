-- Shows track popularity by genre based on units sold.

SELECT
    t.track_id,
    t.track_name,
    t.genre_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id

GROUP BY
    t.track_id,
    t.track_name,
    t.genre_name

ORDER BY units_sold DESC;