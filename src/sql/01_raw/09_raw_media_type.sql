CREATE OR REPLACE TABLE raw_media_type AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/MediaType.csv',
format => 'csv',
header => true);