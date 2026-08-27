-- Loads Chinook music-related CSV files into the Raw layer.
-- Raw tables preserve source values without cleaning or transformation.
-- CREATE TABLE IF NOT EXISTS prevents existing Raw data from being overwritten.

USE CATALOG workspace;
USE SCHEMA d3_raw;


-- Loads the Track source.
-- quote, escape, and multiLine handle quoted text in track names and composers.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.track_raw
USING DELTA
AS
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


-- Loads album details.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.album_raw
USING DELTA
AS
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


-- Loads artist details.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.artist_raw
USING DELTA
AS
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


-- Loads music genre details.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.genre_raw
USING DELTA
AS
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


-- Loads media type details.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.media_type_raw
USING DELTA
AS
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


-- Loads playlist details.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.playlist_raw
USING DELTA
AS
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


-- Loads the bridge table between playlists and tracks.

CREATE TABLE IF NOT EXISTS workspace.d3_raw.playlist_track_raw
USING DELTA
AS
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