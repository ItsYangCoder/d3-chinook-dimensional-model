--Source check for Invoice Raw
SELECT COUNT(*) AS invoice_row_count
FROM workspace.d3_raw.invoice_raw;

--Null Check for Invoice Raw
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN InvoiceId IS NULL THEN 1 END) AS null_invoice_id,
    COUNT(CASE WHEN CustomerId IS NULL THEN 1 END) AS null_customer_id,
    COUNT(CASE WHEN InvoiceDate IS NULL THEN 1 END) AS null_invoice_date,
    COUNT(CASE WHEN BillingAddress IS NULL THEN 1 END) AS null_billing_address,
    COUNT(CASE WHEN BillingCity IS NULL THEN 1 END) AS null_billing_city,
    COUNT(CASE WHEN BillingState IS NULL THEN 1 END) AS null_billing_state,
    COUNT(CASE WHEN BillingCountry IS NULL THEN 1 END) AS null_billing_country,
    COUNT(CASE WHEN BillingPostalCode IS NULL THEN 1 END) AS null_billing_postalcode,
    COUNT(CASE WHEN Total IS NULL THEN 1 END) AS null_total
FROM workspace.d3_raw.invoice_raw;

-- Check for invalid dates
SELECT COUNT(*) AS implausible_invoice_date
FROM workspace.d3_raw.invoice_raw
WHERE InvoiceDate < TIMESTAMP('2000-01-01 00:00:00')
   OR InvoiceDate > CURRENT_TIMESTAMP;

-- Check for invalid totals (zero or negative)
SELECT COUNT(*) AS invalid_total
FROM workspace.d3_raw.invoice_raw
WHERE Total IS NULL OR Total <= 0;


--Source Check for InvoiceLine
SELECT COUNT(*) AS invoiceLine_row_count
FROM workspace.d3_raw.invoice_line_raw;

--Null Check
SELECT
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN InvoiceLineId IS NULL THEN 1 END) AS null_invoice_line_id,
    COUNT(CASE WHEN InvoiceId IS NULL THEN 1 END) AS null_invoice_id,
    COUNT(CASE WHEN TrackId IS NULL THEN 1 END) AS null_track_id,
    COUNT(CASE WHEN UnitPrice IS NULL THEN 1 END) AS null_unit_price,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS null_quantity
FROM workspace.d3_raw.invoice_line_raw;

-- Check for invalid quantities
SELECT COUNT(*) AS invalid_quantity
FROM workspace.d3_raw.invoice_line_raw
WHERE Quantity IS NULL OR Quantity <= 0;

-- Check for invalid unit prices
SELECT COUNT(*) AS invalid_unit_price
FROM workspace.d3_raw.invoice_line_raw
WHERE UnitPrice IS NULL OR UnitPrice <= 0;
