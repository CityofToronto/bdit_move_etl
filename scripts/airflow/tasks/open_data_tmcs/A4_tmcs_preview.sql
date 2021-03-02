CREATE SCHEMA IF NOT EXISTS open_data;

CREATE OR REPLACE VIEW open_data.tmcs_preview AS (
  WITH tmcs_locations_recent AS (
    SELECT * FROM open_data.tmcs_locations
    ORDER BY latest_count_date DESC
    LIMIT 1000
  )
  SELECT tj.*
  FROM tmcs_locations_recent tlr
  JOIN open_data.tmcs_joined tj ON tlr.latest_count_id = tj.count_id
  ORDER BY tj.count_id ASC, tj.time_start ASC
);
