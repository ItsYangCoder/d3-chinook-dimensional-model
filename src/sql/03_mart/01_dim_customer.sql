-- Creates one reporting-ready row per customer.

CREATE TABLE IF NOT EXISTS workspace.d3_mart.dim_customer AS
SELECT
    -- Business keys and attributes
    customer_id,
    first_name,
    last_name,
    full_name,
    email_address,
    phone_number,
    address,
    city,
    country,
    postal_code,
    support_rep_id,

    -- Mart metadata
    CURRENT_DATE() AS mart_load_date,
    CURRENT_TIMESTAMP() AS mart_entry_date

FROM workspace.d3_clean.customer_clean;