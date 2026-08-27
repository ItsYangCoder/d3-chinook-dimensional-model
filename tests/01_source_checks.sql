-- Raw-layer quality checks.
-- These checks are separate from Raw ingestion scripts.
-- They only inspect existing Raw tables and do not modify data.

USE CATALOG workspace;
USE SCHEMA d3_raw;


-- Checks the row count of every Raw table.

SELECT 'customer_raw' AS table_name, COUNT(*) AS row_count
FROM workspace.d3_raw.customer_raw

UNION ALL

SELECT 'employee_raw', COUNT(*)
FROM workspace.d3_raw.employee_raw

UNION ALL

SELECT 'invoice_raw', COUNT(*)
FROM workspace.d3_raw.invoice_raw

UNION ALL

SELECT 'invoice_line_raw', COUNT(*)
FROM workspace.d3_raw.invoice_line_raw

UNION ALL

SELECT 'track_raw', COUNT(*)
FROM workspace.d3_raw.track_raw

UNION ALL

SELECT 'album_raw', COUNT(*)
FROM workspace.d3_raw.album_raw

UNION ALL

SELECT 'artist_raw', COUNT(*)
FROM workspace.d3_raw.artist_raw

UNION ALL

SELECT 'genre_raw', COUNT(*)
FROM workspace.d3_raw.genre_raw

UNION ALL

SELECT 'media_type_raw', COUNT(*)
FROM workspace.d3_raw.media_type_raw

UNION ALL

SELECT 'playlist_raw', COUNT(*)
FROM workspace.d3_raw.playlist_raw

UNION ALL

SELECT 'playlist_track_raw', COUNT(*)
FROM workspace.d3_raw.playlist_track_raw

ORDER BY table_name;


-- Checks Customer IDs.

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT CustomerId) AS unique_customer_ids,
    SUM(CASE WHEN CustomerId IS NULL THEN 1 ELSE 0 END) AS missing_customer_ids
FROM workspace.d3_raw.customer_raw;


-- Checks Employee IDs and missing employee IDs.

SELECT
    COUNT(*) AS total_employees,
    COUNT(DISTINCT EmployeeId) AS unique_employee_ids,
    SUM(CASE WHEN EmployeeId IS NULL THEN 1 ELSE 0 END) AS missing_employee_ids
FROM workspace.d3_raw.employee_raw;


-- Shows duplicate Employee IDs.
-- Expected result: no rows.

SELECT
    EmployeeId,
    COUNT(*) AS record_count
FROM workspace.d3_raw.employee_raw
GROUP BY EmployeeId
HAVING COUNT(*) > 1;


-- Checks invalid employee reporting relationships.
-- NULL ReportsTo is allowed for a top-level manager.
-- Expected result: no rows.

SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    e.ReportsTo
FROM workspace.d3_raw.employee_raw e
LEFT JOIN workspace.d3_raw.employee_raw m
    ON e.ReportsTo = m.EmployeeId
WHERE e.ReportsTo IS NOT NULL
    AND m.EmployeeId IS NULL;


-- Checks Invoice and InvoiceLine identifiers.

SELECT
    COUNT(*) AS total_invoices,
    COUNT(DISTINCT InvoiceId) AS unique_invoice_ids,
    SUM(CASE WHEN InvoiceId IS NULL THEN 1 ELSE 0 END) AS missing_invoice_ids
FROM workspace.d3_raw.invoice_raw;


SELECT
    COUNT(*) AS total_invoice_lines,
    COUNT(DISTINCT InvoiceLineId) AS unique_invoice_line_ids,
    SUM(CASE WHEN InvoiceLineId IS NULL THEN 1 ELSE 0 END) AS missing_invoice_line_ids
FROM workspace.d3_raw.invoice_line_raw;


-- Checks Track IDs and source prices.

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT TrackId) AS unique_track_ids,
    SUM(CASE WHEN TrackId IS NULL THEN 1 ELSE 0 END) AS missing_track_ids,
    MIN(UnitPrice) AS minimum_price,
    MAX(UnitPrice) AS maximum_price
FROM workspace.d3_raw.track_raw;


-- Checks relationships across the Raw music tables.

SELECT
    SUM(CASE WHEN al.AlbumId IS NULL THEN 1 ELSE 0 END)
        AS tracks_without_album,

    SUM(CASE WHEN ar.ArtistId IS NULL THEN 1 ELSE 0 END)
        AS tracks_without_artist,

    SUM(CASE WHEN g.GenreId IS NULL THEN 1 ELSE 0 END)
        AS tracks_without_genre,

    SUM(CASE WHEN mt.MediaTypeId IS NULL THEN 1 ELSE 0 END)
        AS tracks_without_media_type

FROM workspace.d3_raw.track_raw t
LEFT JOIN workspace.d3_raw.album_raw al
    ON t.AlbumId = al.AlbumId
LEFT JOIN workspace.d3_raw.artist_raw ar
    ON al.ArtistId = ar.ArtistId
LEFT JOIN workspace.d3_raw.genre_raw g
    ON t.GenreId = g.GenreId
LEFT JOIN workspace.d3_raw.media_type_raw mt
    ON t.MediaTypeId = mt.MediaTypeId;