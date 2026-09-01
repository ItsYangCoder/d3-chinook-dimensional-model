-- Cleans and standardizes music-related data.
-- Data-quality checks are kept in a separate test script.

CREATE TABLE IF NOT EXISTS workspace.d3_clean.track_clean AS
SELECT
    -- Primary and foreign keys
    TRY_CAST(TrackId AS INT) AS track_id,
    TRY_CAST(AlbumId AS INT) AS album_id,
    TRY_CAST(MediaTypeId AS INT) AS media_type_id,
    TRY_CAST(GenreId AS INT) AS genre_id,

    -- Track details
    TRIM(Name) AS track_name,
    TRIM(Composer) AS composer,

    -- Track measurements
    TRY_CAST(Milliseconds AS BIGINT) AS milliseconds,
    TRY_CAST(Bytes AS BIGINT) AS bytes,
    TRY_CAST(UnitPrice AS DECIMAL(10, 2)) AS unit_price,

    -- Batch and audit metadata
    CURRENT_DATE() AS load_date,
    CURRENT_TIMESTAMP() AS entry_date

FROM workspace.d3_raw.track_raw
WHERE TrackId IS NOT NULL;