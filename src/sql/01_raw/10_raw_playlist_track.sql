CREATE OR REPLACE TABLE raw_playlist_track AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/PlaylistTrack.csv',
format => 'csv',
header => true);