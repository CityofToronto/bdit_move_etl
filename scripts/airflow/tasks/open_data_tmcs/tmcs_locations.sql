CREATE SCHEMA IF NOT EXISTS open_data;

CREATE OR REPLACE VIEW open_data.tmcs_locations AS (
  SELECT DISTINCT ON (location_id)
    location_id,
    lng,
    lat,
    centreline_type,
    centreline_id,
    traffic_signal_id,
    count_info_id AS latest_count_info_id,
    count_date AS latest_count_date
  FROM open_data.tmcs_metadata
  ORDER BY location_id ASC, count_date DESC
);
