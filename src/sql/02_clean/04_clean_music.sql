-- Cleans the track data from the Raw layer.

USE CATALOG workspace;
USE SCHEMA d3_clean;

CREATE OR REPLACE TABLE workspace.d3_clean.track_clean AS
SELECT
    TRY_CAST(TrackId AS BIGINT) AS track_id,
    TRIM(Name) AS track_name,
    TRY_CAST(AlbumId AS BIGINT) AS album_id,
    TRY_CAST(MediaTypeId AS BIGINT) AS media_type_id,
    TRY_CAST(GenreId AS BIGINT) AS genre_id,
    TRIM(Composer) AS composer,
    TRY_CAST(Milliseconds AS BIGINT) AS milliseconds,
    TRY_CAST(Bytes AS BIGINT) AS bytes,
    TRY_CAST(UnitPrice AS DECIMAL(10, 2)) AS unit_price
FROM workspace.d3_raw.track_raw;

-- Checks the cleaned track data.

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT track_id) AS unique_track_ids,

    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END)
        AS missing_track_ids,

    SUM(CASE WHEN track_name IS NULL OR track_name = '' THEN 1 ELSE 0 END)
        AS missing_track_names,

    SUM(CASE WHEN album_id IS NULL THEN 1 ELSE 0 END)
        AS missing_album_ids,

    SUM(CASE WHEN media_type_id IS NULL THEN 1 ELSE 0 END)
        AS missing_media_type_ids,

    SUM(CASE WHEN genre_id IS NULL THEN 1 ELSE 0 END)
        AS missing_genre_ids,

    SUM(CASE WHEN milliseconds IS NULL OR milliseconds <= 0 THEN 1 ELSE 0 END)
        AS invalid_milliseconds,

    SUM(CASE WHEN bytes IS NULL OR bytes <= 0 THEN 1 ELSE 0 END)
        AS invalid_bytes,

    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END)
        AS invalid_prices,

    MIN(unit_price) AS minimum_price,
    MAX(unit_price) AS maximum_price

FROM workspace.d3_clean.track_clean;

-- Checks for duplicate track IDs.

SELECT
    track_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_clean.track_clean
GROUP BY track_id
HAVING COUNT(*) > 1;