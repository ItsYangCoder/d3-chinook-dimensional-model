-- Cleans and standardizes employee information.
-- Data-quality checks are kept in a separate test script.

CREATE OR REPLACE TABLE workspace.d3_clean.employee_clean
USING DELTA
AS
SELECT
    -- Primary and reporting keys
    CAST(EmployeeId AS INT) AS employee_id,
    CAST(ReportsTo AS INT) AS reports_to,

    -- Employee name
    TRIM(FirstName) AS first_name,
    TRIM(LastName) AS last_name,
    TRIM(CONCAT(TRIM(FirstName), ' ', TRIM(LastName))) AS full_name,

    -- Job information
    TRIM(Title) AS title,

    -- Dates
    CAST(BirthDate AS DATE) AS birth_date,
    CAST(HireDate AS DATE) AS hire_date,

    -- Address and location
    TRIM(Address) AS address,
    TRIM(City) AS city,
    UPPER(TRIM(State)) AS state,
    TRIM(Country) AS country,
    TRIM(PostalCode) AS postal_code,

    -- Contact information
    TRIM(Phone) AS phone_number,
    TRIM(Fax) AS fax_number,
    LOWER(TRIM(Email)) AS email_address,

    -- Batch and audit metadata
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS entry_date

FROM workspace.d3_raw.employee_raw
WHERE EmployeeId IS NOT NULL;