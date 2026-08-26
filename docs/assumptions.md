# Under Development

This file will be updated as the Chinook project progresses.

# Assumptions

## Music Table

### Source Granularity

Each record in `raw_track` represents a single track in the Chinook music catalog and is uniquely identified by `track_id`.

### Column Shift Recovery

During CSV ingestion, some track titles containing embedded commas and quotation marks caused values to shift into adjacent columns.

A recovery rule was applied when:

```sql
AlbumId RLIKE '[^0-9]'
```

This condition identifies records where `AlbumId` contains text instead of a numeric value, indicating a column-shifting issue.

Validation confirmed that:

- 4 records were affected
- All affected records followed the same column-shift pattern
- Recovery logic successfully restored the affected fields

### Unit Price Handling

Original `UnitPrice` values are preserved for valid records.

For corrupted records and invalid prices, a fallback value of `0.99` is applied.

The following logic is used:

```sql
CASE
    WHEN AlbumId RLIKE '[^0-9]' THEN 0.99
    WHEN TRY_CAST(UnitPrice AS DECIMAL(10,2)) > 10 THEN 0.99
    ELSE TRY_CAST(UnitPrice AS DECIMAL(10,2))
END AS unit_price
```

Validation results:

- Recovered records: 4
- Minimum price: 0.99
- Maximum price: 1.99
- Distinct prices: 2
- Remaining invalid prices (>10): 0

### Relationship Assumptions

Tracks may optionally be associated with albums, artists, media types, and genres.

`LEFT JOIN` operations are used when creating `dim_track` to preserve all track records, including those with missing or unmatched reference data.

Albums are linked to artists through the album-to-artist relationship maintained in the source data.

### Data Quality Validation

The following checks were performed before creating downstream dimensional models:

- Validation of malformed primary keys across raw music tables
- Inspection of corrupted records in `raw_track`
- Identification of orphaned foreign keys
- Validation of recovered records affected by column shifting
- Validation of cleaned unit prices
- Verification that no remaining track prices exceed expected business values

### Data Preservation

Records are repaired whenever possible rather than removed.

This approach minimizes data loss, maintains row-level completeness, and ensures that downstream dimension and fact tables remain suitable for analytics and reporting.