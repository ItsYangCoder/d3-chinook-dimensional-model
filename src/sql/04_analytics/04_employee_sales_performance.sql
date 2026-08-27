-- Employee Sales Performance Analysis
-- Business Question:
-- Which sales-support employees generated the most revenue by quarter?

USE CATALOG workspace;
USE SCHEMA d3_mart;


-- 1. Preview Fact Sales

SELECT *
FROM workspace.d3_mart.fact_sales
LIMIT 5;


-- 2. Preview Customer Dimension

SELECT *
FROM workspace.d3_mart.dim_customer
LIMIT 5;


-- 3. Preview Employee Dimension

SELECT *
FROM workspace.d3_mart.dim_employee
LIMIT 5;


-- 4. Preview Date Dimension

SELECT *
FROM workspace.d3_mart.dim_date
LIMIT 5;


-- 5. Check Customer and Employee Relationship

SELECT
    c.customer_id,
    c.full_name AS customer_name,
    c.support_rep_id,
    e.employee_key,
    e.full_name AS employee_name,
    e.title
FROM workspace.d3_mart.dim_customer c

LEFT JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

LIMIT 10;


-- 6. Check Fact Sales and Employee Connection

SELECT
    f.invoice_line_id,
    f.invoice_id,
    f.customer_id,
    c.support_rep_id,
    e.employee_key,
    e.full_name AS employee_name,
    e.title,
    f.quantity,
    f.unit_price,
    f.line_amount
FROM workspace.d3_mart.fact_sales f

JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

LIMIT 10;


-- 7. Check Sales Support Agents

SELECT
    employee_key,
    employee_id,
    full_name,
    title
FROM workspace.d3_mart.dim_employee

WHERE title = 'Sales Support Agent'

ORDER BY employee_id;


-- 8. Total Revenue by Employee

SELECT
    e.employee_id,
    e.full_name AS employee_name,
    e.title,
    ROUND(SUM(f.line_amount), 2) AS total_revenue
FROM workspace.d3_mart.fact_sales f

JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

WHERE e.title = 'Sales Support Agent'

GROUP BY
    e.employee_id,
    e.full_name,
    e.title

ORDER BY total_revenue DESC;


-- 9. Employee Revenue by Year and Quarter

SELECT
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name AS employee_name,
    ROUND(SUM(f.line_amount), 2) AS total_revenue
FROM workspace.d3_mart.fact_sales f

JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key

WHERE e.title = 'Sales Support Agent'

GROUP BY
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name

ORDER BY
    d.year,
    d.quarter,
    total_revenue DESC;


-- 10. Final Employee Sales Performance

SELECT
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name AS employee_name,

    ROUND(SUM(f.line_amount), 2) AS total_revenue,

    SUM(f.quantity) AS units_sold,

    COUNT(DISTINCT f.invoice_id) AS total_invoices

FROM workspace.d3_mart.fact_sales f

JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key

WHERE e.title = 'Sales Support Agent'

GROUP BY
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name

ORDER BY
    d.year,
    d.quarter,
    total_revenue DESC;


-- 11. Validate Fact Sales Row Count

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(DISTINCT invoice_line_id) AS unique_invoice_lines
FROM workspace.d3_mart.fact_sales;


-- Expected:
-- total_fact_rows = 2240
-- unique_invoice_lines = 2240


-- 12. Validate Number of Sales Support Agents

SELECT
    COUNT(*) AS total_sales_support_agents
FROM workspace.d3_mart.dim_employee
WHERE title = 'Sales Support Agent';


-- Expected:
-- total_sales_support_agents = 3


-- 13. Check Customers Without Matching Employee

SELECT
    c.customer_id,
    c.full_name,
    c.support_rep_id
FROM workspace.d3_mart.dim_customer c

LEFT JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

WHERE e.employee_key IS NULL;


-- Expected:
-- 0 rows


-- 14. Check Fact Sales Rows Without Employee Connection

SELECT
    f.invoice_line_id,
    f.customer_id
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

LEFT JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

WHERE e.employee_key IS NULL;


-- Expected:
-- 0 rows


-- 15. Compare Total Revenue

SELECT
    ROUND(SUM(line_amount), 2) AS fact_total_revenue
FROM workspace.d3_mart.fact_sales;


SELECT
    ROUND(SUM(f.line_amount), 2) AS employee_linked_revenue
FROM workspace.d3_mart.fact_sales f

JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_key

WHERE e.title = 'Sales Support Agent';