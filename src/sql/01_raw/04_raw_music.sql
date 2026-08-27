-- Loads the original Employee CSV file into the shared Raw schema.
-- Business values are kept unchanged.

USE CATALOG workspace;

USE SCHEMA d3_raw;

-- Create the Raw Track table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_track USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Track.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_track;

-- Create the Raw Album table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_album USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Album.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_album;

-- Create the Raw Artist table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_artist USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Artist.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_artist;

-- Create the Raw Genre table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_genre USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Genre.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_genre;

-- Create the Raw Media Type table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_media_type USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/MediaType.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_media_type;

-- Create the Raw Playlist Track table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_playlist_track USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/PlaylistTrack.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_playlist_track;

-- Create the Raw Playlist table.

CREATE OR REPLACE TABLE workspace.d3_raw.raw_playlist USING DELTA AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Playlist.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_playlist;