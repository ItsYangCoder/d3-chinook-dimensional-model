CREATE OR REPLACE TABLE workspace.d3_mart.dim_track
USING DELTA
AS
SELECT 
    t.track_id,
    t.track_name,
    t.composer,
    t.milliseconds,
    t.bytes,
    t.unit_price,
    al.Title AS album_title,
    ar.Name AS artist_name,
    m.Name AS media_type_name,
    g.Name AS genre_name
FROM workspace.d3_clean.track_clean t
LEFT JOIN workspace.d3_raw.raw_album al
    ON t.album_id = TRY_CAST(al.AlbumId AS INT)
LEFT JOIN workspace.d3_raw.raw_artist ar
    ON TRY_CAST(al.ArtistId AS INT) = TRY_CAST(ar.ArtistId AS INT)
LEFT JOIN workspace.d3_raw.raw_media_type m
    ON t.media_type_id = TRY_CAST(m.MediaTypeId AS INT)
LEFT JOIN workspace.d3_raw.raw_genre g
    ON t.genre_id = TRY_CAST(g.GenreId AS INT);

-- Relationship Validation
SELECT 
    COUNT(*) AS total_tracks,
    COUNT(album_title) AS tracks_with_album,
    COUNT(artist_name) AS tracks_with_artist,
    COUNT(media_type_name) AS tracks_with_media_type,
    COUNT(genre_name) AS tracks_with_genre
FROM workspace.d3_mart.dim_track;

-- Total Rows and Unique Tracks Validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT track_id) AS unique_tracks
FROM workspace.d3_mart.dim_track;

-- Missing or Invalid Track IDs Validation
SELECT
    COUNT(*) AS invalid_track_ids
FROM workspace.d3_mart.dim_track
WHERE track_id IS NULL;

-- Duplicate Track IDs Validation
SELECT
    track_id,
    COUNT(*) AS duplicate_count
FROM workspace.d3_mart.dim_track
GROUP BY track_id
HAVING COUNT(*) > 1;

-- Price Distribution Validation
SELECT
    unit_price,
    COUNT(*) AS row_count
FROM workspace.d3_mart.dim_track
GROUP BY unit_price
ORDER BY unit_price;

-- Unexpected Price Validation
SELECT
    track_id,
    track_name,
    unit_price
FROM workspace.d3_mart.dim_track
WHERE unit_price NOT IN (0.99, 1.99);

-- Final Row Count Validation
SELECT
    COUNT(*) AS dim_track_rows
FROM workspace.d3_mart.dim_track;