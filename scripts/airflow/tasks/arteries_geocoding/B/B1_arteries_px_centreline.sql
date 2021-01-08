CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_px_centreline AS (
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
    gts.geom
  FROM arterycodes_traffic_signals ats
  JOIN location_search.traffic_signal lsts ON ats.px = lsts.px
  JOIN gis.traffic_signal gts ON ats.px = gts.px::int
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_px_centreline_arterycode ON counts2.arteries_px_centreline (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_px_centreline;
