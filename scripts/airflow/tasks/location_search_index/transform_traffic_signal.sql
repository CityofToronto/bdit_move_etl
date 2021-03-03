CREATE SCHEMA IF NOT EXISTS location_search;

--
-- We deliberately create `location_search.traffic_signal` as a table, so that we can use it for
-- downstream processes that need information about traffic signals.
--
-- By doing so, we isolate those processes from changes to upstream datasets, so long as the
-- schema below remains unchanged.
--
CREATE TABLE IF NOT EXISTS location_search.traffic_signal (
  px INT NOT NULL,
  "centrelineType" INT,
  "centrelineId" INT,
  geom GEOMETRY(POINT, 4326) NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS ls_traffic_signal_px ON location_search.traffic_signal (px);
CREATE INDEX IF NOT EXISTS ls_traffic_signal_centreline ON location_search.traffic_signal ("centrelineType", "centrelineId");

TRUNCATE TABLE location_search.traffic_signal;

INSERT INTO location_search.traffic_signal (
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
        20
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
        20
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
      ELSE NULL
    END AS "centrelineType",
    COALESCE(tsi."centrelineId", tsm."centrelineId") AS "centrelineId",
    ts.geom
  FROM ts
  LEFT JOIN traffic_signal_intersections tsi ON ts.px = tsi.px
  LEFT JOIN traffic_signal_midblocks tsm ON ts.px = tsm.px
);
