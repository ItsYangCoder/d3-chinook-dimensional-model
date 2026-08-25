CREATE OR REPLACE TABLE raw_artist AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Artist.csv',
format => 'csv',
header => true);