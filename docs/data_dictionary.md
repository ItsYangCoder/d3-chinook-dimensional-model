# Under Development

This file will be updated as the Chinook project progresses.

| Column Name | Data Type | Key Type | Description | Source Mapping / Logic |
| :--- | :--- | :--- | :--- | :--- |
| `track_id` | `INT` | Primary Key (PK) | Unique identifier for each music track | `raw_track.TrackId` (casted) |
| `track_name` | `VARCHAR(255)` | Attribute | Title of the track | Recombined `Name` + `AlbumId` on shifted rows; quotes stripped |
| `composer` | `VARCHAR(255)` | Attribute | Composer or writer of the track | Realigned from `Milliseconds` on shifted rows |
| `milliseconds` | `INT` | Attribute | Track length in milliseconds | Realigned from `Bytes` on shifted rows |
| `bytes` | `INT` | Attribute | File size in bytes | Realigned from `UnitPrice` on shifted rows |
| `unit_price` | `DECIMAL(10,2)` | Attribute | Retail price per track | Realigned or defaulted to `0.99` |
| `album_title` | `VARCHAR(255)` | Attribute | Title of the associated album | `raw_album.Title` via `album_id` |
| `artist_name` | `VARCHAR(255)` | Attribute | Name of the track artist | `raw_artist.Name` via `ArtistId` |
| `media_type_name` | `VARCHAR(255)` | Attribute | Format type (e.g., MPEG, AAC) | `raw_media_type.Name` via `media_type_id` |
| `genre_name` | `VARCHAR(255)` | Attribute | Music category/genre | `raw_genre.Name` via `genre_id` |