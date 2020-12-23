CREATE SCHEMA IF NOT EXISTS location_search;

CREATE MATERIALIZED VIEW IF NOT EXISTS location_search.traffic_signal AS (
  WITH ts AS (
    SELECT px::int AS px, geom
    FROM gis.traffic_signal
  ), traffic_signal_intersections AS (
    SELECT
      ts.px,
      u."centrelineId"
    FROM ts
    INNER JOIN LATERAL
    (
      SELECT
        "centrelineId",
        ST_Distance(
          ST_Transform(geom, 2952),
          ST_Transform(ts.geom, 2952)
        ) AS geom_dist
      FROM centreline.intersections
      WHERE ST_DWithin(
        ST_Transform(geom, 2952),
        ST_Transform(ts.geom, 2952),
        30
      )
      ORDER BY geom_dist ASC
      LIMIT 1
    ) u ON true
  ), traffic_signal_midblocks AS (
    SELECT
      ts.px,
      u."centrelineId"
    FROM ts
    INNER JOIN LATERAL
    (
      SELECT
        "centrelineId",
        ST_Distance(
          ST_Transform(geom, 2952),
          ST_Transform(ts.geom, 2952)
        ) AS geom_dist
      FROM centreline.midblocks
      WHERE ST_DWithin(
        ST_Transform(geom, 2952),
        ST_Transform(ts.geom, 2952),
        30
      )
      ORDER BY geom_dist ASC
      LIMIT 1
    ) u ON true
  )
  SELECT
    ts.px,
    CASE
      WHEN tsi."centrelineId" IS NOT NULL THEN 2
      WHEN tsm."centrelineId" IS NOT NULL THEN 1
    END AS "centrelineType",
    COALESCE(tsi."centrelineId", tsm."centrelineId") AS "centrelineId"
  FROM ts
  LEFT JOIN traffic_signal_intersections tsi ON ts.px = tsi.px
  LEFT JOIN traffic_signal_midblocks tsm ON ts.px = tsm.px
);
CREATE UNIQUE INDEX IF NOT EXISTS ls_traffic_signal_px ON location_search.traffic_signal (px);

REFRESH MATERIALIZED VIEW CONCURRENTLY location_search.traffic_signal;
