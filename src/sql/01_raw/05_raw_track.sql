CREATE OR REPLACE TABLE raw_track AS
SELECT *
FROM read_files(
'/Volumes/workspace/bronze/1st_volume/shared/week05/chinook_csv/Track.csv',
format => 'csv',
header => true);

SELECT COUNT(*) FROM raw_track;