CREATE SCHEMA IF NOT EXISTS open_data;

CREATE OR REPLACE VIEW open_data.tmcs_locations AS (
  SELECT DISTINCT ON (location_id)
    location_id,
    location,
    lng,
    lat,
    centreline_type,
    centreline_id,
    px,
    count_id AS latest_count_id,
    count_date AS latest_count_date
  FROM open_data.tmcs_count_metadata
  ORDER BY location_id ASC, count_date DESC
);
