-- POPULAR TRACKS BY QUANTITY SOLD
-- What are the top 20 tracks by total units sold,
-- and which album and artist do they belong to?


SELECT
    t.track_id,
    t.track_name,
    t.album_title,
    t.artist_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id

GROUP BY
    t.track_id,
    t.track_name,
    t.album_title,
    t.artist_name

ORDER BY units_sold DESC
LIMIT 20;


-- TRACK POPULARITY BY GENRE
-- Which genres have the highest sales volume and revenue?

SELECT
    t.genre_name,
    COUNT(DISTINCT t.track_id) AS track_count,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id

GROUP BY
    t.genre_name

ORDER BY units_sold DESC;


-- TRACK POPULARITY BY PLAYLIST
-- Which playlists contain the most-purchased tracks?

SELECT
    p.Name AS playlist_name,
    COUNT(DISTINCT t.track_id) AS track_count,
    SUM(f.quantity) AS units_sold,
    SUM(f.line_amount) AS revenue,
    COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM workspace.d3_mart.fact_sales f

INNER JOIN workspace.d3_mart.dim_track t
    ON f.track_id = t.track_id

INNER JOIN workspace.d3_raw.playlist_track_raw pt
    ON t.track_id = TRY_CAST(pt.TrackId AS INT)

INNER JOIN workspace.d3_raw.playlist_raw p
    ON TRY_CAST(pt.PlaylistId AS INT) = TRY_CAST(p.PlaylistId AS INT)

GROUP BY
    p.Name

ORDER BY units_sold DESC;