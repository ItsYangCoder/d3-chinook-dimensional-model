-- Clean layer validation checks.
-- These checks validate the cleaned Customer, Sales, Employee, and Music tables.

USE CATALOG workspace;


-- Customer clean checks

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN full_name IS NULL OR TRIM(full_name) = '' THEN 1 ELSE 0 END) AS missing_full_name,
    SUM(CASE WHEN email_address IS NULL OR TRIM(email_address) = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN support_rep_id IS NULL THEN 1 ELSE 0 END) AS missing_support_rep_id,
    SUM(CASE WHEN load_date IS NULL THEN 1 ELSE 0 END) AS missing_load_date,
    SUM(CASE WHEN entry_date IS NULL THEN 1 ELSE 0 END) AS missing_entry_date
FROM workspace.d3_clean.customer_clean;


-- Invoice clean checks

SELECT
    COUNT(*) AS total_invoices,
    COUNT(DISTINCT invoice_id) AS unique_invoice_ids,
    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS missing_invoice_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS missing_invoice_date,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS missing_total_amount,
    SUM(CASE WHEN total_amount <= 0 THEN 1 ELSE 0 END) AS invalid_total_amount,
    SUM(CASE WHEN load_date IS NULL THEN 1 ELSE 0 END) AS missing_load_date,
    SUM(CASE WHEN entry_date IS NULL THEN 1 ELSE 0 END) AS missing_entry_date
FROM workspace.d3_clean.invoice_clean;


-- Invoice line clean checks

SELECT
    COUNT(*) AS total_invoice_lines,
    COUNT(DISTINCT invoice_line_id) AS unique_invoice_line_ids,
    SUM(CASE WHEN invoice_line_id IS NULL THEN 1 ELSE 0 END) AS missing_invoice_line_id,
    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS missing_invoice_id,
    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END) AS missing_track_id,
    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_unit_price,
    SUM(CASE WHEN line_amount IS NULL OR line_amount <> quantity * unit_price THEN 1 ELSE 0 END) AS invalid_line_amount,
    SUM(CASE WHEN load_date IS NULL THEN 1 ELSE 0 END) AS missing_load_date,
    SUM(CASE WHEN entry_date IS NULL THEN 1 ELSE 0 END) AS missing_entry_date
FROM workspace.d3_clean.invoice_line_clean;


-- Employee clean checks

SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT employee_id) AS unique_employee_ids,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS missing_employee_id,
    SUM(CASE WHEN full_name IS NULL OR TRIM(full_name) = '' THEN 1 ELSE 0 END) AS missing_full_name,
    SUM(CASE WHEN title IS NULL OR TRIM(title) = '' THEN 1 ELSE 0 END) AS missing_title,
    SUM(CASE WHEN email_address IS NULL OR TRIM(email_address) = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS missing_hire_date,
    SUM(CASE WHEN load_date IS NULL THEN 1 ELSE 0 END) AS missing_load_date,
    SUM(CASE WHEN entry_date IS NULL THEN 1 ELSE 0 END) AS missing_entry_date
FROM workspace.d3_clean.employee_clean;


-- Invalid employee reporting relationships.
-- Expected result: no rows.

SELECT
    e.employee_id,
    e.full_name,
    e.reports_to
FROM workspace.d3_clean.employee_clean e
LEFT JOIN workspace.d3_clean.employee_clean manager
    ON e.reports_to = manager.employee_id
WHERE e.reports_to IS NOT NULL
  AND manager.employee_id IS NULL;


-- Track clean checks

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT track_id) AS unique_track_ids,
    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END) AS missing_track_ids,
    SUM(CASE WHEN track_name IS NULL OR TRIM(track_name) = '' THEN 1 ELSE 0 END) AS missing_track_names,
    SUM(CASE WHEN album_id IS NULL THEN 1 ELSE 0 END) AS missing_album_ids,
    SUM(CASE WHEN media_type_id IS NULL THEN 1 ELSE 0 END) AS missing_media_type_ids,
    SUM(CASE WHEN genre_id IS NULL THEN 1 ELSE 0 END) AS missing_genre_ids,
    SUM(CASE WHEN milliseconds IS NULL OR milliseconds <= 0 THEN 1 ELSE 0 END) AS invalid_milliseconds,
    SUM(CASE WHEN bytes IS NULL OR bytes <= 0 THEN 1 ELSE 0 END) AS invalid_bytes,
    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_prices,
    SUM(CASE WHEN load_date IS NULL THEN 1 ELSE 0 END) AS missing_load_date,
    SUM(CASE WHEN entry_date IS NULL THEN 1 ELSE 0 END) AS missing_entry_date,
    MIN(unit_price) AS minimum_price,
    MAX(unit_price) AS maximum_price
FROM workspace.d3_clean.track_clean;


-- Duplicate track IDs.
-- Expected result: no rows.

SELECT
    track_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_clean.track_clean
GROUP BY track_id
HAVING COUNT(*) > 1;