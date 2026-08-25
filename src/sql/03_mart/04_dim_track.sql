CREATE OR REPLACE TABLE dim_track AS
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
FROM stg_track t
LEFT JOIN raw_album al ON t.album_id = TRY_CAST(al.AlbumId AS INT)
LEFT JOIN raw_artist ar ON TRY_CAST(al.ArtistId AS INT) = TRY_CAST(ar.ArtistId AS INT)
LEFT JOIN raw_media_type m ON t.media_type_id = TRY_CAST(m.MediaTypeId AS INT)
LEFT JOIN raw_genre g ON t.genre_id = TRY_CAST(g.GenreId AS INT);

-- Verification
SELECT 
    COUNT(*) AS total_tracks,
    COUNT(album_title) AS tracks_with_album,
    COUNT(artist_name) AS tracks_with_artist,
    COUNT(media_type_name) AS tracks_with_media_type,
    COUNT(genre_name) AS tracks_with_genre
FROM dim_track;