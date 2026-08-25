CREATE OR REPLACE TABLE raw_genre AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Genre.csv',
format => 'csv',
header => true);
