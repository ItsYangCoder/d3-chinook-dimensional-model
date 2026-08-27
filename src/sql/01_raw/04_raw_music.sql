-- Loads the original Chinook music CSV files into the Raw layer.
-- No business values are changed in this file.

USE CATALOG workspace;
USE SCHEMA d3_raw;

-- Loads the Track data.

CREATE OR REPLACE TABLE workspace.d3_raw.track_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Track.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the Album data.

CREATE OR REPLACE TABLE workspace.d3_raw.album_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Album.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the Artist data.

CREATE OR REPLACE TABLE workspace.d3_raw.artist_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Artist.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the Genre data.

CREATE OR REPLACE TABLE workspace.d3_raw.genre_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Genre.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the Media Type data.

CREATE OR REPLACE TABLE workspace.d3_raw.media_type_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/MediaType.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the Playlist data.

CREATE OR REPLACE TABLE workspace.d3_raw.playlist_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Playlist.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Loads the relationship between playlists and tracks.

CREATE OR REPLACE TABLE workspace.d3_raw.playlist_track_raw AS
SELECT *
FROM read_files(
    '/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/PlaylistTrack.csv',
    format => 'csv',
    header => true,
    inferSchema => true,
    quote => '"',
    escape => '"',
    multiLine => true
);

-- Checks the Raw Music row counts.

SELECT
    'track_raw' AS table_name,
    COUNT(*) AS row_count
FROM workspace.d3_raw.track_raw

UNION ALL

SELECT
    'album_raw',
    COUNT(*)
FROM workspace.d3_raw.album_raw

UNION ALL

SELECT
    'artist_raw',
    COUNT(*)
FROM workspace.d3_raw.artist_raw

UNION ALL

SELECT
    'genre_raw',
    COUNT(*)
FROM workspace.d3_raw.genre_raw

UNION ALL

SELECT
    'media_type_raw',
    COUNT(*)
FROM workspace.d3_raw.media_type_raw

UNION ALL

SELECT
    'playlist_raw',
    COUNT(*)
FROM workspace.d3_raw.playlist_raw

UNION ALL

SELECT
    'playlist_track_raw',
    COUNT(*)
FROM workspace.d3_raw.playlist_track_raw;

-- Checks the Track identifiers and prices.

SELECT
    COUNT(*) AS total_tracks,
    COUNT(DISTINCT TrackId) AS unique_track_ids,
    SUM(CASE WHEN TrackId IS NULL THEN 1 ELSE 0 END)
        AS missing_track_ids,
    MIN(UnitPrice) AS minimum_price,
    MAX(UnitPrice) AS maximum_price
FROM workspace.d3_raw.track_raw;

-- Checks the relationships between the Raw Music tables.

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