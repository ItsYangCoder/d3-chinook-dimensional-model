

-- Clean and standardize customer fields
CREATE OR REPLACE TABLE workspace.d3_clean.customer_clean AS
SELECT
    -- Primary & Foreign Keys
    CAST(CustomerId AS INT) AS customer_id,
    CAST(SupportRepId AS INT) AS support_rep_id,

    -- Customer Name Standardization
    TRIM(FirstName) AS first_name,
    TRIM(LastName) AS last_name,
    TRIM(CONCAT(TRIM(FirstName), ' ', TRIM(LastName))) AS full_name,
    TRIM(Company) AS company_name,

    -- Address & Location Standardization
    TRIM(Address) AS address,
    TRIM(City) AS city,
    UPPER(TRIM(State)) AS state,
    TRIM(Country) AS country,
    TRIM(PostalCode) AS postal_code,

    -- Contact Information Cleaning
    TRIM(Phone) AS phone_number,
    TRIM(Fax) AS fax_number,
    LOWER(TRIM(Email)) AS email_address,

    -- Audit Metadata Column
    CURRENT_TIMESTAMP()AS cleaned_at

FROM workspace.d3_raw.customer_raw
WHERE CustomerId IS NOT NULL;

-- Viewing the Cleaned Customer Table
SELECT *
FROM workspace.d3_clean.customer_clean;

