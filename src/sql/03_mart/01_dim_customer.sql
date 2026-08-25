-- Create one reporting-ready row per customer in dim_customer

CREATE OR REPLACE TABLE workspace.d3_mart.dim_customer AS
SELECT
    -- Business Keys & Attributes
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

    -- Mart Audit Column
    CURRENT_TIMESTAMP() AS mart_created_at
FROM workspace.d3_clean.customer_clean;

SELECT * FROM workspace.d3_mart.dim_customer;