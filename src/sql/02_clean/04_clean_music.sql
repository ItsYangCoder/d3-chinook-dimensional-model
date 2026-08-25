-- 1. Check for non-numeric or malformed primary keys across raw tables
-- NOTE: Selects uniform columns (table_name, primary_key_value) across all UNION blocks.

SELECT 'raw_track' AS table_name, TrackId AS invalid_value
FROM raw_track 
WHERE TRY_CAST(TrackId AS BIGINT) IS NULL

UNION ALL

SELECT 'raw_album' AS table_name, AlbumId AS invalid_value
FROM raw_album 
WHERE TRY_CAST(AlbumId AS BIGINT) IS NULL

UNION ALL

SELECT 'raw_artist' AS table_name, ArtistId AS invalid_value
FROM raw_artist 
WHERE TRY_CAST(ArtistId AS BIGINT) IS NULL

UNION ALL

SELECT 'raw_genre' AS table_name, GenreId AS invalid_value
FROM raw_genre 
WHERE TRY_CAST(GenreId AS BIGINT) IS NULL

UNION ALL

SELECT 'raw_media_type' AS table_name, MediaTypeId AS invalid_value
FROM raw_media_type 
WHERE TRY_CAST(MediaTypeId AS BIGINT) IS NULL;


-- 2. Inspect full row details for corrupted records in raw_track
-- NOTE: Run this to see all fields for rows in raw_track where numeric/key values are malformed.

SELECT *
FROM raw_track
WHERE TRY_CAST(TrackId AS BIGINT) IS NULL
   OR TRY_CAST(AlbumId AS BIGINT) IS NULL
   OR TRY_CAST(MediaTypeId AS BIGINT) IS NULL
   OR TRY_CAST(GenreId AS BIGINT) IS NULL
   OR TRY_CAST(Milliseconds AS BIGINT) IS NULL
   OR TRY_CAST(Bytes AS BIGINT) IS NULL
   OR TRY_CAST(UnitPrice AS DECIMAL(10,2)) IS NULL;


-- 3. Check for orphaned foreign keys in raw_track
-- NOTE: Finds valid tracks that reference missing keys in album, media_type, or genre tables.

SELECT 
    t.TrackId,
    t.AlbumId,
    t.MediaTypeId,
    t.GenreId,
    CASE WHEN al.AlbumId IS NULL THEN 'Missing Album' END AS album_issue,
    CASE WHEN m.MediaTypeId IS NULL THEN 'Missing Media Type' END AS media_type_issue,
    CASE WHEN g.GenreId IS NULL THEN 'Missing Genre' END AS genre_issue
FROM raw_track t
LEFT JOIN raw_album al ON TRY_CAST(t.AlbumId AS BIGINT) = TRY_CAST(al.AlbumId AS BIGINT)
LEFT JOIN raw_media_type m ON TRY_CAST(t.MediaTypeId AS BIGINT) = TRY_CAST(m.MediaTypeId AS BIGINT)
LEFT JOIN raw_genre g ON TRY_CAST(t.GenreId AS BIGINT) = TRY_CAST(g.GenreId AS BIGINT)
WHERE TRY_CAST(t.TrackId AS BIGINT) IS NOT NULL
  AND (al.AlbumId IS NULL OR m.MediaTypeId IS NULL OR g.GenreId IS NULL);

  -- Staging layer
CREATE OR REPLACE TABLE stg_track AS
SELECT 
    CAST(TrackId AS INT) AS track_id,
    
    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN CONCAT(Name, ',', AlbumId)
        ELSE Name
    END AS track_name,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN TRY_CAST(MediaTypeId AS INT) 
        ELSE TRY_CAST(AlbumId AS INT) 
    END AS album_id,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN TRY_CAST(GenreId AS INT) 
        ELSE TRY_CAST(MediaTypeId AS INT) 
    END AS media_type_id,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN TRY_CAST(Composer AS INT) 
        ELSE TRY_CAST(GenreId AS INT) 
    END AS genre_id,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN Milliseconds 
        ELSE Composer 
    END AS composer,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN TRY_CAST(Bytes AS INT) 
        ELSE TRY_CAST(Milliseconds AS INT) 
    END AS milliseconds,

    CASE 
        WHEN AlbumId RLIKE '[^0-9]' THEN TRY_CAST(UnitPrice AS INT) 
        ELSE TRY_CAST(Bytes AS INT) 
    END AS bytes,

    0.99 AS unit_price
FROM raw_track;

SELECT COUNT(*) FROM stg_track;