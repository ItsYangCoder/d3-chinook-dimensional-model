# Under Development

This file will be updated as the Chinook project progresses.

**Assumptions**

Primary Source Granularity: Each distinct row in raw_track represents a unique track entry in the music catalog (track_id).

Column Shift Etiology: Unescaped commas within quote-delimited text fields (such as classical titles and multi-artist composer strings) caused rightward field shifts during raw CSV ingestion.

Fallback Values: Corrupted or shifted unit_price fields default to standard catalog pricing (0.99) when missing or uncastable.

Join Hierarchy: Tracks maintain optional associations with albums (LEFT JOIN), while albums map to artists. Unassigned tracks are preserved to prevent orphaned keys in fact tables.

 **Assumption: Billing State Recovery**

**What we do:**
If BillingState is missing, we recover it using a reference table (billing_state_enriched) that maps each city to its correct state and country.

**Source of values:**
The mapping comes from known city‑to‑state relationships stored in the reference table.

**Rule:**
Recovery is applied only when the original BillingState is NULL. Existing values are kept as‑is.

**Reason:**  
This ensures invoice data is complete and standardized for reporting and analysis.