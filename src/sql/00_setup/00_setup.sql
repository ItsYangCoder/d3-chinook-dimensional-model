-- Creates the shared schemas for the D3 Chinook project.

USE CATALOG workspace;

-- Raw tables loaded from the original CSV files.
CREATE SCHEMA IF NOT EXISTS d3_raw;

-- Cleaned and standardized tables.
CREATE SCHEMA IF NOT EXISTS d3_clean;

-- Dimension and fact tables.
CREATE SCHEMA IF NOT EXISTS d3_mart;

-- Data-quality results and invalid records.
CREATE SCHEMA IF NOT EXISTS d3_quality;


-- Check that the project schemas are available.
SHOW SCHEMAS IN workspace;