-- Cleans and standardizes sales-related tables.
-- Data-quality checks are kept in a separate test script.

CREATE OR REPLACE TABLE workspace.d3_clean.invoice_clean AS
SELECT
    -- Primary and foreign keys
    CAST(InvoiceId AS INT) AS invoice_id,
    CAST(CustomerId AS INT) AS customer_id,

    -- Invoice date
    CAST(InvoiceDate AS DATE) AS invoice_date,

    -- Billing information
    TRIM(BillingAddress) AS billing_address,
    TRIM(BillingCity) AS billing_city,
    UPPER(TRIM(BillingState)) AS billing_state,
    TRIM(BillingCountry) AS billing_country,
    TRIM(BillingPostalCode) AS billing_postal_code,

    -- Invoice amount
    CAST(Total AS DECIMAL(12, 2)) AS total_amount,

    -- Batch and audit metadata
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS entry_date

FROM workspace.d3_raw.invoice_raw
WHERE InvoiceId IS NOT NULL;


CREATE OR REPLACE TABLE workspace.d3_clean.invoice_line_clean AS
SELECT
    -- Primary and foreign keys
    CAST(InvoiceLineId AS INT) AS invoice_line_id,
    CAST(InvoiceId AS INT) AS invoice_id,
    CAST(TrackId AS INT) AS track_id,

    -- Sales details
    CAST(UnitPrice AS DECIMAL(10, 2)) AS unit_price,
    CAST(Quantity AS INT) AS quantity,

    -- Computed line amount
    CAST(
        CAST(UnitPrice AS DECIMAL(10, 2)) * CAST(Quantity AS INT)
        AS DECIMAL(12, 2)
    ) AS line_amount,

    -- Batch and audit metadata
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS entry_date

FROM workspace.d3_raw.invoice_line_raw
WHERE InvoiceLineId IS NOT NULL;