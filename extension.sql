-- Enable extensions (run in psql or pgAdmin)
CREATE EXTENSION pg_trgm;       -- Fuzzy text search
CREATE EXTENSION hstore;        -- Key-value storage
CREATE EXTENSION postgis;       -- Geospatial queries (requires postgis image)
CREATE EXTENSION uuid-ossp;     -- Generate UUIDs