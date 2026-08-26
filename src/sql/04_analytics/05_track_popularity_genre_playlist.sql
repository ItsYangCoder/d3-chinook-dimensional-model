SELECT 
    t.genre_name,
    COUNT(DISTINCT t.track_id) AS total_catalog_tracks,
    COUNT(il.InvoiceLineId) AS total_times_purchased,
    SUM(TRY_CAST(il.Quantity AS INT)) AS total_units_sold,
    ROUND(SUM(TRY_CAST(il.UnitPrice AS DECIMAL(10,2)) * TRY_CAST(il.Quantity AS INT)), 2) AS total_revenue
FROM dim_track t
INNER JOIN raw_invoice_line il ON t.track_id = TRY_CAST(il.TrackId AS INT)
GROUP BY t.genre_name
ORDER BY total_units_sold DESC;

-- 2A. Most Popular Genres Featured in Playlists
SELECT 
    t.genre_name,
    COUNT(DISTINCT pt.PlaylistId) AS featured_in_playlists_count,
    COUNT(pt.TrackId) AS total_playlist_track_entries
FROM dim_track t
INNER JOIN raw_playlist_track pt ON t.track_id = TRY_CAST(pt.TrackId AS INT)
GROUP BY t.genre_name
ORDER BY total_playlist_track_entries DESC;


-- 2B. Top Playlists by Total Track Count and Genre Diversity
SELECT 
    p.Name AS playlist_name,
    COUNT(DISTINCT pt.TrackId) AS total_tracks,
    COUNT(DISTINCT t.genre_name) AS distinct_genres_included
FROM raw_playlist p
INNER JOIN raw_playlist_track pt ON TRY_CAST(p.PlaylistId AS INT) = TRY_CAST(pt.PlaylistId AS INT)
INNER JOIN dim_track t ON TRY_CAST(pt.TrackId AS INT) = t.track_id
GROUP BY p.Name, p.PlaylistId
ORDER BY total_tracks DESC;