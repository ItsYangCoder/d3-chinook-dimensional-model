-- Row count
SELECT COUNT(*) AS invoice_clean_row_count
FROM workspace.d3_clean.invoice_clean;

-- Null checks
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN invoice_id IS NULL THEN 1 END) AS null_invoice_id,
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS null_customer_id,
    COUNT(CASE WHEN invoice_date IS NULL THEN 1 END) AS null_invoice_date,
    COUNT(CASE WHEN total IS NULL THEN 1 END) AS null_total
FROM workspace.d3_clean.invoice_clean;

-- Invalid totals
SELECT COUNT(*) AS invalid_totals
FROM workspace.d3_clean.invoice_clean
WHERE total <= 0;


-- Row count
SELECT COUNT(*) AS invoice_line_clean_row_count
FROM workspace.d3_clean.invoice_line_clean;

-- Null checks
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN invoice_line_id IS NULL THEN 1 END) AS null_invoice_line_id,
    COUNT(CASE WHEN invoice_id IS NULL THEN 1 END) AS null_invoice_id,
    COUNT(CASE WHEN track_id IS NULL THEN 1 END) AS null_track_id,
    COUNT(CASE WHEN quantity IS NULL THEN 1 END) AS null_quantity,
    COUNT(CASE WHEN unit_price IS NULL THEN 1 END) AS null_unit_price
FROM workspace.d3_clean.invoice_line_clean;

-- Invalid values
SELECT
    COUNT(*) AS invalid_quantity
FROM workspace.d3_clean.invoice_line_clean
WHERE quantity <= 0;

SELECT
    COUNT(*) AS invalid_unit_price
FROM workspace.d3_clean.invoice_line_clean
WHERE unit_price <= 0;


-- Row count
SELECT COUNT(*) AS clean_sales_row_count
FROM workspace.d3_clean.clean_sales;

-- Null checks
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN invoice_line_id IS NULL THEN 1 END) AS null_invoice_line_id,
    COUNT(CASE WHEN invoice_id IS NULL THEN 1 END) AS null_invoice_id,
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS null_customer_id,
    COUNT(CASE WHEN track_id IS NULL THEN 1 END) AS null_track_id,
    COUNT(CASE WHEN invoice_date IS NULL THEN 1 END) AS null_invoice_date,
    COUNT(CASE WHEN quantity IS NULL THEN 1 END) AS null_quantity,
    COUNT(CASE WHEN unit_price IS NULL THEN 1 END) AS null_unit_price,
    COUNT(CASE WHEN line_amount IS NULL THEN 1 END) AS null_line_amount
FROM workspace.d3_clean.clean_sales;

-- Invalid values
SELECT
    COUNT(*) AS invalid_quantity
FROM workspace.d3_clean.clean_sales
WHERE quantity <= 0;

SELECT
    COUNT(*) AS invalid_unit_price
FROM workspace.d3_clean.clean_sales
WHERE unit_price <= 0;

-- Validation: line_amount should equal quantity * unit_price
SELECT COUNT(*) AS mismatched_line_amount
FROM workspace.d3_clean.clean_sales
WHERE line_amount <> (quantity * unit_price);

-- Validation: invoice_total should equal sum of line_amount per invoice
SELECT invoice_id, invoice_total, SUM(line_amount) AS calc_total
FROM workspace.d3_clean.clean_sales
GROUP BY invoice_id, invoice_total
HAVING invoice_total <> SUM(line_amount);
