-- Groups customers into spending tiers based on total spending.

SELECT
    c.customer_id,
    c.full_name,
    c.country,
    COUNT(DISTINCT f.invoice_id) AS invoice_count,
    SUM(f.quantity) AS units_purchased,
    SUM(f.line_amount) AS total_spending,

    CASE
        WHEN SUM(f.line_amount) >= 45.00 THEN 'High Spender'
        WHEN SUM(f.line_amount) >= 40.00 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_tier

FROM workspace.d3_mart.dim_customer c

INNER JOIN workspace.d3_mart.fact_sales f
    ON c.customer_id = f.customer_id

GROUP BY
    c.customer_id,
    c.full_name,
    c.country

ORDER BY total_spending DESC;