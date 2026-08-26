-- File reserved for the assigned project task.
-- SQL will be added after source inspection is complete.CREATE OR REPLACE TABLE Artist AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Artist.csv',
format => 'csv',
header => true);

CREATE OR REPLACE TABLE Album AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Album.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE Customer AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Customer.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE Employee AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Employee.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE Genre AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Genre.csv',
format => 'csv',
header => true
);





CREATE OR REPLACE TABLE Invoice AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Invoice.csv',
format => 'csv',
header => true
);



CREATE OR REPLACE TABLE InvoiceLine AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/InvoiceLine.csv',
format => 'csv',
header => true
);



CREATE OR REPLACE TABLE MediaType AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/MediaType.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE Playlist AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Playlist.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE PlaylisTrack AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/PlaylistTrack.csv',
format => 'csv',
header => true
);

CREATE OR REPLACE TABLE Track AS
SELECT *
FROM read_files(
'/Volumes/d4_individual/new/ftw-b12-de-r2/shared/week05/chinook_csv/Track.csv',
format => 'csv',
header => true
);