-- Mart layer validation checks.
-- Validates all dimension tables and the sales fact table.

USE CATALOG workspace;


-- Customer dimension checks

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN full_name IS NULL OR TRIM(full_name) = '' THEN 1 ELSE 0 END) AS missing_full_name,
    SUM(CASE WHEN support_rep_id IS NULL THEN 1 ELSE 0 END) AS missing_support_rep_id,
    SUM(CASE WHEN mart_load_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_load_date,
    SUM(CASE WHEN mart_entry_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_entry_date
FROM workspace.d3_mart.dim_customer;


-- Date dimension checks

SELECT
    COUNT(*) AS total_dates,
    COUNT(DISTINCT date_key) AS unique_date_keys,
    COUNT(DISTINCT full_date) AS unique_full_dates,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS missing_date_key,
    SUM(CASE WHEN full_date IS NULL THEN 1 ELSE 0 END) AS missing_full_date,
    SUM(CASE WHEN mart_load_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_load_date,
    SUM(CASE WHEN mart_entry_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_entry_date,
    MIN(full_date) AS earliest_invoice_date,
    MAX(full_date) AS latest_invoice_date
FROM workspace.d3_mart.dim_date;


-- Employee dimension checks

SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT employee_key) AS unique_employee_keys,
    COUNT(DISTINCT employee_id) AS unique_employee_ids,
    SUM(CASE WHEN employee_key IS NULL THEN 1 ELSE 0 END) AS missing_employee_key,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN full_name IS NULL OR TRIM(full_name) = '' THEN 1 ELSE 0 END) AS missing_full_name,
    SUM(CASE WHEN title IS NULL OR TRIM(title) = '' THEN 1 ELSE 0 END) AS missing_title,
    SUM(CASE WHEN mart_load_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_load_date,
    SUM(CASE WHEN mart_entry_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_entry_date
FROM workspace.d3_mart.dim_employee;


-- Track dimension checks

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT track_id) AS unique_track_ids,
    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END) AS missing_track_ids,
    SUM(CASE WHEN track_name IS NULL OR TRIM(track_name) = '' THEN 1 ELSE 0 END) AS missing_track_names,
    SUM(CASE WHEN album_title IS NULL OR TRIM(album_title) = '' THEN 1 ELSE 0 END) AS missing_album_titles,
    SUM(CASE WHEN artist_name IS NULL OR TRIM(artist_name) = '' THEN 1 ELSE 0 END) AS missing_artist_names,
    SUM(CASE WHEN media_type_name IS NULL OR TRIM(media_type_name) = '' THEN 1 ELSE 0 END) AS missing_media_types,
    SUM(CASE WHEN genre_name IS NULL OR TRIM(genre_name) = '' THEN 1 ELSE 0 END) AS missing_genres,
    SUM(CASE WHEN mart_load_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_load_date,
    SUM(CASE WHEN mart_entry_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_entry_date,
    MIN(unit_price) AS minimum_price,
    MAX(unit_price) AS maximum_price
FROM workspace.d3_mart.dim_track;


-- Duplicate track IDs.
-- Expected result: no rows.

SELECT
    track_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_mart.dim_track
GROUP BY track_id
HAVING COUNT(*) > 1;


-- Sales fact table checks

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(DISTINCT invoice_line_id) AS unique_invoice_lines,
    SUM(CASE WHEN invoice_line_id IS NULL THEN 1 ELSE 0 END) AS missing_invoice_line_ids,
    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS missing_invoice_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_ids,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS missing_date_keys,
    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END) AS missing_track_ids,
    SUM(CASE WHEN employee_key IS NULL THEN 1 ELSE 0 END) AS missing_employee_keys,
    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantities,
    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_unit_prices,
    SUM(CASE WHEN line_amount IS NULL OR line_amount <= 0 THEN 1 ELSE 0 END) AS invalid_line_amounts,
    SUM(CASE WHEN mart_load_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_load_date,
    SUM(CASE WHEN mart_entry_date IS NULL THEN 1 ELSE 0 END) AS missing_mart_entry_date
FROM workspace.d3_mart.fact_sales;


-- Duplicate invoice line IDs.
-- Expected result: no rows.

SELECT
    invoice_line_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_mart.fact_sales
GROUP BY invoice_line_id
HAVING COUNT(*) > 1;


-- Invoice total reconciliation.
-- Expected result: 0.

SELECT
    COUNT(*) AS invoices_with_difference
FROM (
    SELECT
        f.invoice_id,
        SUM(f.line_amount) AS calculated_total,
        MAX(i.total_amount) AS invoice_total
    FROM workspace.d3_mart.fact_sales f
    LEFT JOIN workspace.d3_clean.invoice_clean i
        ON f.invoice_id = i.invoice_id
    GROUP BY f.invoice_id
    HAVING ROUND(SUM(f.line_amount), 2) <> ROUND(MAX(i.total_amount), 2)
);