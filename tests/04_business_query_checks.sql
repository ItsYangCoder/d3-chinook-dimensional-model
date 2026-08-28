-- =============================== BUSINESS QUERY CHECKS ============================



-- Check 1:
-- Confirms that fact_sales has the expected sales records.

SELECT
    COUNT(*) AS total_fact_rows,
    SUM(quantity) AS total_units_sold,
    SUM(line_amount) AS total_revenue
FROM workspace.d3_mart.fact_sales;


-- Check 2:
-- Confirms that Top Revenue by Genre per Country keeps all sales rows
-- after joining fact_sales to dim_customer and dim_track.

SELECT
    COUNT(*) AS joined_rows,
    SUM(f.quantity) AS joined_units_sold,
    SUM(f.line_amount) AS joined_revenue,
    SUM(
        CASE
            WHEN c.country IS NULL OR TRIM(c.country) = '' THEN 1
            ELSE 0
        END
    ) AS missing_country,
    SUM(
        CASE
            WHEN t.genre_name IS NULL OR TRIM(t.genre_name) = '' THEN 1
            ELSE 0
        END
    ) AS missing_genre
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id

LEFT JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id;


-- Check 3:
-- Confirms that Customer Spending Tiers includes customers with sales.

SELECT
    COUNT(DISTINCT c.customer_id) AS customers_with_sales,
    SUM(f.quantity) AS total_units_purchased,
    SUM(f.line_amount) AS total_customer_spending
FROM workspace.d3_mart.dim_customer c

INNER JOIN workspace.d3_mart.fact_sales f
    ON c.customer_id = f.customer_id;


-- Check 4:
-- Checks if any customer has no sales record.

SELECT
    c.customer_id,
    c.full_name,
    c.country
FROM workspace.d3_mart.dim_customer c

LEFT JOIN workspace.d3_mart.fact_sales f
    ON c.customer_id = f.customer_id

WHERE f.customer_id IS NULL;



-- Check 5:
-- Confirms that monthly sales trend keeps the same total sales
-- as fact_sales after joining to dim_date.

SELECT
    COUNT(*) AS joined_rows,
    SUM(f.quantity) AS joined_units_sold,
    SUM(f.line_amount) AS joined_revenue,
    SUM(
        CASE
            WHEN d.date_key IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_date_key
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key;


-- Check 6:
-- Confirms that employee sales performance keeps the same total sales
-- after joining fact_sales to dim_employee and dim_date.

SELECT
    COUNT(*) AS joined_rows,
    SUM(f.quantity) AS joined_units_sold,
    SUM(f.line_amount) AS joined_revenue,
    SUM(
        CASE
            WHEN e.employee_key IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_employee_key,
    SUM(
        CASE
            WHEN d.date_key IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_date_key
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_employee e
    ON f.employee_key = e.employee_key

LEFT JOIN workspace.d3_mart.dim_date d
    ON f.date_key = d.date_key;


-- Check 7:
-- Confirms that track popularity keeps the same total sales
-- after joining fact_sales to dim_track.

SELECT
    COUNT(*) AS joined_rows,
    SUM(f.quantity) AS joined_units_sold,
    SUM(f.line_amount) AS joined_revenue,
    SUM(
        CASE
            WHEN t.track_id IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_track_id,
    SUM(
        CASE
            WHEN t.track_name IS NULL OR TRIM(t.track_name) = '' THEN 1
            ELSE 0
        END
    ) AS missing_track_name,
    SUM(
        CASE
            WHEN t.genre_name IS NULL OR TRIM(t.genre_name) = '' THEN 1
            ELSE 0
        END
    ) AS missing_genre
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id;


-- Check 8:
-- Confirms that regional customer behavior keeps the same total sales
-- after joining fact_sales to dim_customer.

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT c.customer_id) AS customers_with_sales,
    SUM(f.quantity) AS joined_units_purchased,
    SUM(f.line_amount) AS joined_revenue,
    SUM(
        CASE
            WHEN c.country IS NULL OR TRIM(c.country) = '' THEN 1
            ELSE 0
        END
    ) AS missing_country
FROM workspace.d3_mart.fact_sales f

LEFT JOIN workspace.d3_mart.dim_customer c
    ON f.customer_id = c.customer_id;