CREATE SCHEMA IF NOT EXISTS centreline;

--
-- We deliberately create `centreline.midblocks_base` as a table to isolate downstream
-- processes from changes to upstream datasets.
--
CREATE TABLE IF NOT EXISTS centreline.midblocks_base (
  "centrelineId" INT NOT NULL,
  "centrelineType" INT NOT NULL,
  "featureCode" INT NOT NULL,
  "fnode" INT NOT NULL,
  "geom" GEOMETRY(LINESTRING, 4326) NOT NULL,
  "lat" DOUBLE PRECISION NOT NULL,
  "lng" DOUBLE PRECISION NOT NULL,
  "midblockName" VARCHAR NOT NULL,
  "roadId" INT NOT NULL,
  "tnode" INT NOT NULL
);

TRUNCATE TABLE centreline.midblocks_base;

INSERT INTO centreline.midblocks_base (
  SELECT
    gc.centreline::INT AS "centrelineId",
    1 AS "centrelineType",
    gc.feature_co AS "featureCode",
    gc.from_inter::INT AS "fnode",
    ST_LineMerge(gc.geom) AS "geom",
    ST_Y(ST_ClosestPoint(gc.geom, ST_Centroid(gc.geom))) AS "lat",
    ST_X(ST_ClosestPoint(gc.geom, ST_Centroid(gc.geom))) AS "lng",
    gc.linear_n00 AS "midblockName",
    gc.linear_nam::INT AS "roadId",
    gc.to_interse::INT AS "tnode"
  FROM gis.centreline gc
);
