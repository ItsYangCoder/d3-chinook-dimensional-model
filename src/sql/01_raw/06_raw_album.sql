CREATE OR REPLACE TABLE raw_album AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Album.csv',
format => 'csv',
header => true);