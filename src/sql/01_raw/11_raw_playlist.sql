CREATE OR REPLACE TABLE raw_playlist AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Playlist.csv',
format => 'csv',
header => true);