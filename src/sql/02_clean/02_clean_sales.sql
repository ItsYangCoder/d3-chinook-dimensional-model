-- City Mapping for Missing Billing State
CREATE OR REPLACE TABLE workspace.d3_clean.billing_state_enriched (
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255)
);

-- TODO: Document source of mapping (official dataset or manual curation)
INSERT INTO workspace.d3_clean.billing_state_enriched VALUES
('Stuttgart','Baden-Württemberg','Germany'),
('Oslo','Oslo','Norway'),
('Brussels','Brussels-Capital Region','Belgium'),
('Frankfurt','Hesse','Germany'),
('Berlin','Berlin','Germany'),
('Paris','Île-de-France','France'),
('Bordeaux','Nouvelle-Aquitaine','France'),
('London','England','United Kingdom'),
('Edinburgh','Scotland','United Kingdom'),
('Santiago','Santiago Metropolitan','Chile'),
('Bangalore','Karnataka','India'),
('Lisbon','Lisbon District','Portugal'),
('Madrid','Community of Madrid','Spain'),
('Stockholm','Stockholm County','Sweden'),
('Prague','Prague','Czech Republic'),
('Helsinki','Uusimaa','Finland'),
('Vienne','Auvergne-Rhône-Alpes','France'),
('Copenhagen','Capital Region','Denmark'),
('Warsaw','Masovian Voivodeship','Poland'),
('Dijon','Bourgogne-Franche-Comté','France'),
('Budapest','Central Hungary','Hungary'),
('Lyon','Auvergne-Rhône-Alpes','France'),
('Buenos Aires','Buenos Aires','Argentina'),
('Delhi','Delhi (NCT)','India'),
('Porto','Porto District','Portugal');

-- Clean Invoice Raw
CREATE OR REPLACE TABLE workspace.d3_clean.invoice_clean AS
SELECT DISTINCT
    CAST(i.InvoiceId AS BIGINT) AS invoice_id,       
    CAST(i.CustomerId AS BIGINT) AS customer_id,     
    CAST(i.InvoiceDate AS DATE) AS invoice_date,     
    CAST(i.Total AS DECIMAL(10,2)) AS total,        

    -- Standardize Format
    TRIM(i.BillingAddress) AS billing_address,       
    TRIM(i.BillingCity) AS billing_city,             

    -- Preserve original and recovered billing state separately
    TRIM(i.BillingState) AS billing_state_source,
    COALESCE(TRIM(i.BillingState), TRIM(bs.state)) AS billing_state_enriched,

    TRIM(i.BillingCountry) AS billing_country,       
    TRIM(i.BillingPostalCode) AS billing_postal_code 
FROM workspace.d3_raw.invoice_raw i
LEFT JOIN workspace.d3_clean.billing_state_enriched bs
    ON i.BillingCity = bs.city
WHERE i.InvoiceDate IS NOT NULL
  AND i.Total > 0;

-- Duplicate check for invoice_clean
SELECT invoice_id, customer_id, COUNT(*) AS duplicate_count
FROM workspace.d3_clean.invoice_clean
GROUP BY invoice_id, customer_id
HAVING COUNT(*) > 1;

-- Row count check
SELECT COUNT(*) AS invoice_count
FROM workspace.d3_clean.invoice_clean;

-- Clean InvoiceLine Raw
CREATE OR REPLACE TABLE workspace.d3_clean.invoice_line_clean AS
SELECT DISTINCT
    CAST(il.InvoiceLineId AS BIGINT) AS invoice_line_id,   
    CAST(il.InvoiceId AS BIGINT) AS invoice_id,           
    CAST(il.TrackId AS BIGINT) AS track_id,               
    CAST(il.UnitPrice AS DECIMAL(10,2)) AS unit_price,     
    CAST(il.Quantity AS INT) AS quantity                   
FROM workspace.d3_raw.invoice_line_raw il
WHERE il.Quantity > 0                                     
  AND il.UnitPrice > 0;      

-- Duplicate check for invoice_line_clean
SELECT invoice_id, invoice_line_id, track_id, COUNT(*) AS duplicate_count_line
FROM workspace.d3_clean.invoice_line_clean
GROUP BY invoice_id, invoice_line_id, track_id
HAVING COUNT(*) > 1;

-- Row count check
SELECT COUNT(*) AS invoice_line_count
FROM workspace.d3_clean.invoice_line_clean;

-- Create Clean Sales Table
CREATE OR REPLACE TABLE workspace.d3_clean.clean_sales AS
SELECT DISTINCT
    il.invoice_line_id,                 
    il.invoice_id,                      
    ci.customer_id,                     
    ci.invoice_date,                    
    ci.total AS invoice_total,         
    il.track_id,                        
    il.quantity,                        
    il.unit_price,                      
    (il.quantity * il.unit_price) AS line_amount, -- computed line amount

    ci.billing_address,               
    ci.billing_city,                    
    ci.billing_state_source,
    ci.billing_state_enriched,
    ci.billing_country,                 
    ci.billing_postal_code             
FROM workspace.d3_clean.invoice_line_clean il
INNER JOIN workspace.d3_clean.invoice_clean ci
    ON il.invoice_id = ci.invoice_id;

-- Duplicate check for clean_sales
SELECT invoice_id, COUNT(*) AS duplicate_sales_count
FROM workspace.d3_clean.clean_sales
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- Row count check
SELECT COUNT(*) AS clean_sales_count
FROM workspace.d3_clean.clean_sales;
