# Under Development

This file will be updated as the Chinook project progresses.

**dim_track**

Checking & Cleaning Methodology
1. Data Auditing & Anomaly Detection

    Executed TRY_CAST and UNION ALL across primary key columns (TrackId, AlbumId, ArtistId, GenreId, MediaTypeId) to detect non-numeric string values caused by parser shifts.

    Identified multi-column alignment errors triggered by classical track titles (e.g., "Eine Kleine Nachtmusik... K. 525").

2. Staging Layer Cleansing (stg_track)

    Applied regex pattern matching (RLIKE '[^0-9]') on AlbumId to isolate corrupted rows from intact rows.

    Recombined split string fragments using CONCAT() to restore full track titles.

    Shifted misaligned positional fields back into their corresponding target attributes (album_id, media_type_id, genre_id, composer, milliseconds, bytes).

    Sanitized quote artifacts using REGEXP_REPLACE().

3. Dimensional Transformation

    Joined stg_track against normalized lookup tables (raw_album, raw_artist, raw_media_type, raw_genre) using LEFT JOIN constraints to preserve full catalog volume.

Validation & Testing
    
Row Count Preservation Test: Verified that the total record count in stg_track matched the primary key count in raw_track (3,503 rows).

Referential Integrity Audit: Ran attribute completeness checks on dim_track to ensure high coverage rates across foreign keys.

Results
    
    Total Records Processed: 3,503

    Successful Foreign Key Joins:

    tracks_with_genre: 3,503 / 3,503 (100%)

    tracks_with_media_type: 3,501 / 3,503 (99.94%)

    tracks_with_album: 3,501 / 3,503 (99.94%)

    tracks_with_artist: 3,501 / 3,503 (99.94%)

Data Quality Verdict
    
Fully stabilized dimension table ready for analytical queries and star schema integration.