-- Clean and standardize customer fields.
-- Data-quality checks are kept in a separate test script.

CREATE TABLE IF NOT EXISTS workspace.d3_clean.customer_clean AS
SELECT
    -- Primary and foreign keys
    CAST(CustomerId AS INT) AS customer_id,
    CAST(SupportRepId AS INT) AS support_rep_id,

    -- Customer name standardization
    TRIM(FirstName) AS first_name,
    TRIM(LastName) AS last_name,
    TRIM(CONCAT(TRIM(FirstName), ' ', TRIM(LastName))) AS full_name,
    TRIM(Company) AS company_name,

    -- Address and location standardization
    TRIM(Address) AS address,
    TRIM(City) AS city,
    UPPER(TRIM(State)) AS state,
    TRIM(Country) AS country,
    TRIM(PostalCode) AS postal_code,

    -- Contact information cleaning
    TRIM(Phone) AS phone_number,
    TRIM(Fax) AS fax_number,
    LOWER(TRIM(Email)) AS email_address,

    -- Batch and audit metadata
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS entry_date

FROM workspace.d3_raw.customer_raw
WHERE CustomerId IS NOT NULL;