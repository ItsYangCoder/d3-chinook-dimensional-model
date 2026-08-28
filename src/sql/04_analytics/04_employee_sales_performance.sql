-- Shows employee sales performance by quarter.

SELECT
    d.year,
    d.quarter,
    e.full_name AS employee_name,
    SUM(f.line_amount) AS revenue,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_employee e
    ON f.employee_key = e.employee_key

INNER JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key

WHERE e.title = 'Sales Support Agent'

GROUP BY
    d.year,
    d.quarter,
    e.full_name

ORDER BY
    d.year,
    d.quarter,
    revenue DESC;