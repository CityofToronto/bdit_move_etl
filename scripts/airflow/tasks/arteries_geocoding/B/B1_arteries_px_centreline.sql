CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_px_centreline AS (
  WITH arterycodes_traffic_signals AS (
    SELECT
      "ARTERYCODE" AS arterycode,
      (regexp_matches("LOCATION"::text, 'PX (\d+)'::text))[1]::int AS px
    FROM "TRAFFIC"."ARTERYDATA"
  )
  SELECT
    ats.arterycode,
    lsts.px,
    lsts."centrelineType",
    lsts."centrelineId",
    lsts.geom
  FROM arterycodes_traffic_signals ats
  JOIN location_search.traffic_signal lsts ON ats.px = lsts.px
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_px_centreline_arterycode ON counts.arteries_px_centreline (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_px_centreline;
