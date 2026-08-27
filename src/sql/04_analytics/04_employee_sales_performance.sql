-- Employee Sales Performance Analysis
-- Business Question:
-- Which sales-support employees generated the most revenue by quarter?

USE CATALOG workspace;

USE SCHEMA d3_mart;

-- Preview Fact Sales

SELECT *
FROM workspace.d3_mart.fact_sales
LIMIT 5;

-- Preview Employee Dimension

SELECT *
FROM workspace.d3_mart.dim_employee
LIMIT 5;

-- Preview Date Dimension

SELECT *
FROM workspace.d3_mart.dim_date
LIMIT 5;

-- Check Employee and Fact Sales connection

SELECT
    f.invoice_line_id,
    c.support_rep_id,
    e.full_name,
    e.title,
    f.quantity,
    f.unit_price,
    f.line_amount
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
LIMIT 10;

-- Check Sales Support Agents only

SELECT
    employee_key,
    employee_id,
    full_name,
    title
FROM workspace.d3_mart.dim_employee
WHERE title = 'Sales Support Agent'
ORDER BY employee_id;

-- Calculate total revenue by employee

SELECT
    e.employee_id,
    e.full_name,
    e.title,
    ROUND(SUM(f.line_amount), 2) AS total_revenue
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
WHERE e.title = 'Sales Support Agent'
GROUP BY
    e.employee_id,
    e.full_name,
    e.title
ORDER BY total_revenue DESC;

-- Calculate Employee Revenue by Year and Quarter

SELECT
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name,
    e.title,
    ROUND(SUM(f.line_amount), 2) AS total_revenue
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key
WHERE e.title = 'Sales Support Agent'
GROUP BY
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name,
    e.title
ORDER BY
    d.year,
    d.quarter,
    total_revenue DESC;

-- Add Quantity Sold

SELECT
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name,
    ROUND(SUM(f.line_amount), 2) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
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

-- Add Number of Invoices

SELECT
    d.year,
    d.quarter,
    e.employee_id,
    e.full_name,
    ROUND(SUM(f.line_amount), 2) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.invoice_id) AS total_invoices
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
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

-- Final Employee Sales Performance Output

SELECT
    d.year,
    d.quarter,
    e.full_name AS employee_name,
    ROUND(SUM(f.line_amount), 2) AS total_revenue,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.invoice_id) AS total_invoices
FROM workspace.d3_mart.fact_sales f
JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id
JOIN workspace.d3_mart.dim_employee e
    ON c.support_rep_id = e.employee_id
JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key
WHERE e.title = 'Sales Support Agent'
GROUP BY
    d.year,
    d.quarter,
    e.full_name
ORDER BY
    d.year,
    d.quarter,
    total_revenue DESC;