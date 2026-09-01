-- Creates the track dimension.
-- One row represents one track.

CREATE TABLE IF NOT EXISTS workspace.d3_mart.dim_track AS
SELECT
    -- Track key and attributes
    t.track_id,
    t.track_name,
    t.composer,
    t.milliseconds,
    t.bytes,
    t.unit_price,

    -- Album and artist attributes
    t.album_id,
    TRIM(al.Title) AS album_title,
    TRY_CAST(al.ArtistId AS INT) AS artist_id,
    TRIM(ar.Name) AS artist_name,

    -- Media type and genre attributes
    t.media_type_id,
    TRIM(mt.Name) AS media_type_name,
    t.genre_id,
    TRIM(g.Name) AS genre_name,

    -- Mart metadata
    CURRENT_DATE() AS mart_load_date,
    CURRENT_TIMESTAMP() AS mart_entry_date

FROM workspace.d3_clean.track_clean t

LEFT JOIN workspace.d3_raw.album_raw al
    ON t.album_id = TRY_CAST(al.AlbumId AS INT)

LEFT JOIN workspace.d3_raw.artist_raw ar
    ON TRY_CAST(al.ArtistId AS INT) = TRY_CAST(ar.ArtistId AS INT)

LEFT JOIN workspace.d3_raw.media_type_raw mt
    ON t.media_type_id = TRY_CAST(mt.MediaTypeId AS INT)

LEFT JOIN workspace.d3_raw.genre_raw g
    ON t.genre_id = TRY_CAST(g.GenreId AS INT)

WHERE t.track_id IS NOT NULL;