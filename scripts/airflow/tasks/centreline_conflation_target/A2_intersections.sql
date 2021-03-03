CREATE SCHEMA IF NOT EXISTS centreline;

--
-- We deliberately create `centreline.intersections` as a table to isolate downstream
-- processes from changes to upstream datasets.
--
CREATE TABLE IF NOT EXISTS centreline.intersections (
  "centrelineId" INT NOT NULL,
  "centrelineType" INT NOT NULL,
  "classification" VARCHAR,
  "description" VARCHAR,
  "featureCode" INT NOT NULL,
  "geom" GEOMETRY(POINT, 4326) NOT NULL,
  "lat" DOUBLE NOT NULL,
  "lng" DOUBLE NOT NULL
);

TRUNCATE TABLE centreline.intersections;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.intersections AS (
  SELECT DISTINCT ON (gci.int_id)
    gci.int_id::int AS "centrelineId",
    2 AS "centrelineType",
    gci.classifi6 AS "classification",
    gci.intersec5 AS "description",
    gci.elevatio9 AS "featureCode",
    gci.geom,
    ST_Y(gci.geom) AS "lat",
    ST_X(gci.geom) AS "lng"
  FROM gis.centreline_intersection gci
  JOIN centreline.intersection_ids USING (int_id)
  WHERE gci.elevatio9 != 509200 OR gci.classifi6 != 'SEUML'
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_intersections_centreline ON centreline.intersections ("centrelineId");
CREATE INDEX IF NOT EXISTS centreline_intersections_geom ON centreline.intersections USING GIST (geom);
CREATE INDEX IF NOT EXISTS centreline_intersections_srid3857_geom ON centreline.intersections USING GIST (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS centreline_intersections_srid2952_geom ON centreline.intersections USING GIST (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.intersections;
