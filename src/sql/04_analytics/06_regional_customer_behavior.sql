-- Shows customer behavior by country.

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT f.invoice_id) AS invoice_count,
    SUM(f.quantity) AS units_purchased,
    SUM(f.line_amount) AS revenue
FROM workspace.d3_mart.dim_customer c

INNER JOIN workspace.d3_mart.fact_sales f
    ON c.customer_id = f.customer_id

GROUP BY c.country

ORDER BY revenue DESC;