CREATE SCHEMA IF NOT EXISTS centreline;

--
-- We deliberately create `centreline.intersections_base` as a table to isolate downstream
-- processes from changes to upstream datasets.
--
CREATE TABLE IF NOT EXISTS centreline.intersections_base (
  "centrelineId" INT NOT NULL,
  "centrelineType" INT NOT NULL,
  "classification" VARCHAR,
  "description" VARCHAR,
  "featureCode" INT NOT NULL,
  "geom" GEOMETRY(POINT, 4326) NOT NULL,
  "lat" DOUBLE PRECISION NOT NULL,
  "lng" DOUBLE PRECISION NOT NULL
);

TRUNCATE TABLE centreline.intersections_base;

INSERT INTO centreline.intersections_base (
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
);
