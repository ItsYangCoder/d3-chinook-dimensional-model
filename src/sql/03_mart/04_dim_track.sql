-- Creates the Track dimension.
-- One row represents one track.

USE CATALOG workspace;
USE SCHEMA d3_mart;

CREATE OR REPLACE TABLE workspace.d3_mart.dim_track AS
SELECT
    t.track_id,
    t.track_name,
    t.composer,
    t.milliseconds,
    t.bytes,
    t.unit_price,
    t.album_id,
    TRIM(al.Title) AS album_title,
    TRY_CAST(al.ArtistId AS BIGINT) AS artist_id,
    TRIM(ar.Name) AS artist_name,
    t.media_type_id,
    TRIM(mt.Name) AS media_type_name,
    t.genre_id,
    TRIM(g.Name) AS genre_name
FROM workspace.d3_clean.track_clean t

LEFT JOIN workspace.d3_raw.album_raw al
    ON t.album_id = al.AlbumId

LEFT JOIN workspace.d3_raw.artist_raw ar
    ON al.ArtistId = ar.ArtistId

LEFT JOIN workspace.d3_raw.media_type_raw mt
    ON t.media_type_id = mt.MediaTypeId

LEFT JOIN workspace.d3_raw.genre_raw g
    ON t.genre_id = g.GenreId;

-- Checks the Track dimension.

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT track_id) AS unique_track_ids,
    SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END)
        AS missing_track_ids,
    SUM(CASE WHEN track_name IS NULL OR track_name = '' THEN 1 ELSE 0 END)
        AS missing_track_names,
    SUM(CASE WHEN album_title IS NULL OR album_title = '' THEN 1 ELSE 0 END)
        AS missing_album_titles,
    SUM(CASE WHEN artist_name IS NULL OR artist_name = '' THEN 1 ELSE 0 END)
        AS missing_artist_names,
    SUM(CASE WHEN media_type_name IS NULL OR media_type_name = '' THEN 1 ELSE 0 END)
        AS missing_media_types,
    SUM(CASE WHEN genre_name IS NULL OR genre_name = '' THEN 1 ELSE 0 END)
        AS missing_genres,
    MIN(unit_price) AS minimum_price,
    MAX(unit_price) AS maximum_price
FROM workspace.d3_mart.dim_track;

-- Checks for duplicate track IDs.

SELECT
    track_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_mart.dim_track
GROUP BY track_id
HAVING COUNT(*) > 1;