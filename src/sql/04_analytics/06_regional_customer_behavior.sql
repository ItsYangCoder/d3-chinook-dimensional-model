-- Regional Customer Behavior

SELECT 
    c.country,
    ROUND(AVG(f.unit_price), 2) AS avg_unit_price,
    SUM(f.quantity) AS total_items_sold
FROM 
    workspace.d3_mart.fact_sales f
JOIN 
    workspace.d3_mart.dim_customer c ON f.customer_id = c.customer_id
GROUP BY 
    c.country
ORDER BY 
    avg_unit_price DESC;