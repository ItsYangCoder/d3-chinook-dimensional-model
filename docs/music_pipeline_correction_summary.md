# Music Pipeline Correction Summary

## Scope

This document explains the corrections made to the Music pipeline assigned to Maki/Joan. The work covers Raw Music ingestion, Track cleaning, the Track dimension, validation, and cleanup of obsolete files and tables.

## Original issue

The first version treated some track titles containing commas and quotation marks as corrupted rows. This led to column-shift recovery logic and a fallback price of `0.99`.

Source validation later confirmed that the original Track CSV was valid when read with the correct CSV settings. The quoted titles were valid source values, not corrupted records.

Validated source results:

- 3,503 Track rows
- 3,503 unique Track IDs
- no missing Track IDs
- valid UnitPrice range of `0.99` to `1.99`
- no missing Album, Artist, Genre, or Media Type relationships

## Decisions

The team agreed on the following:

1. Preserve valid source values instead of reconstructing columns.
2. Remove the column-shift recovery logic.
3. Remove the hardcoded `0.99` fallback.
4. Use consistent schema and table names:
   - `workspace.d3_raw.*_raw`
   - `workspace.d3_clean.track_clean`
   - `workspace.d3_mart.dim_track`
5. Use `LEFT JOIN` when building `dim_track` so all source tracks are preserved.
6. Consolidate all Music Raw loading into one SQL file.

## Corrected pipeline

### Raw

File: `src/sql/01_raw/04_raw_music.sql`

The file loads:

- `track_raw`
- `album_raw`
- `artist_raw`
- `genre_raw`
- `media_type_raw`
- `playlist_raw`
- `playlist_track_raw`

The CSV reader uses quotation, escape, and multiline settings so track names containing commas and quotation marks are parsed correctly.

### Clean

File: `src/sql/02_clean/04_clean_music.sql`

The corrected process creates `workspace.d3_clean.track_clean` directly from `workspace.d3_raw.track_raw`.

The Clean layer:

- standardizes column names
- trims text values
- casts identifiers and numeric fields
- preserves the original UnitPrice
- checks missing values, invalid values, and duplicate Track IDs

### Mart

File: `src/sql/03_mart/04_dim_track.sql`

The corrected process creates `workspace.d3_mart.dim_track`.

One row represents one track. Album, Artist, Media Type, and Genre details are added through `LEFT JOIN` operations.

Final validation:

- 3,503 rows
- 3,503 unique Track IDs
- zero missing Track IDs and names
- zero missing Album, Artist, Media Type, and Genre details
- zero duplicate Track IDs
- UnitPrice range of `0.99` to `1.99`

## Deleted SQL files

The following files were removed:

- `src/sql/01_raw/05_raw_track.sql`
- `src/sql/01_raw/06_raw_album.sql`
- `src/sql/01_raw/07_raw_artist.sql`
- `src/sql/01_raw/08_raw_genre.sql`
- `src/sql/01_raw/09_raw_media_type.sql`
- `src/sql/01_raw/10_raw_playlist_track.sql`
- `src/sql/01_raw/11_raw_playlist.sql`

These files were deleted because their table-loading logic is already included in `04_raw_music.sql`. Keeping both versions would duplicate the same work and could recreate tables using inconsistent names or CSV settings.

Deleting the SQL files did not delete the final Databricks tables.

## Dropped Databricks tables

The following old Raw tables were dropped:

- `workspace.d3_raw.raw_track`
- `workspace.d3_raw.raw_album`
- `workspace.d3_raw.raw_artist`
- `workspace.d3_raw.raw_genre`
- `workspace.d3_raw.raw_media_type`
- `workspace.d3_raw.raw_playlist`
- `workspace.d3_raw.raw_playlist_track`

The old Clean table below was also dropped:

- `workspace.d3_clean.stg_track`

They were dropped because they were obsolete copies created by the earlier naming convention and correction approach.

The final tables use the agreed naming:

- `track_raw`, `album_raw`, `artist_raw`, `genre_raw`, `media_type_raw`, `playlist_raw`, and `playlist_track_raw`
- `track_clean`
- `dim_track`

Cleanup was performed only after the corrected replacement tables passed validation. Customer, Employee, Sales, Date, and other team tables were not removed.

## Git cleanup

The corrected work was merged through PR #35. The older Music PRs were closed because they contained superseded code. Their old branches were deleted after the final correction was safely merged into `main`.

## Final result

The Music pipeline now follows the agreed flow:

`d3_raw Music tables → d3_clean.track_clean → d3_mart.dim_track`

The final version preserves the source data, uses consistent naming, removes unsupported recovery assumptions, and provides validated Track data for `fact_sales` and analytics.
