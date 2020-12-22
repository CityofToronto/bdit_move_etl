CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.midblocks AS (
  SELECT
    va.aadt,
    gc.geo_id::int AS "centrelineId",
    1 AS "centrelineType",
    gc.fcode AS "featureCode",
    gc.fnode::int AS "fnode",
    cmn."fromIntersectionName",
    ST_LineMerge(gc.geom) AS "geom",
    ST_Y(ST_ClosestPoint(gc.geom, ST_Centroid(gc.geom))) AS "lat",
    ST_X(ST_ClosestPoint(gc.geom, ST_Centroid(gc.geom))) AS "lng",
    gc.lf_name AS "midblockName",
    gc.lfn_id AS "roadId",
    gc.tnode::int AS "tnode",
    cmn."toIntersectionName"
  FROM gis.centreline gc
  LEFT JOIN centreline.midblock_names cmn ON gc.geo_id = cmn.geo_id
  LEFT JOIN volume.aadt va ON gc.geo_id = va.centreline_id
  WHERE gc.fcode <= 201803
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_midblocks_centreline ON centreline.midblocks ("centrelineId");
CREATE INDEX IF NOT EXISTS centreline_midblocks_geom ON centreline.midblocks USING GIST (geom);
CREATE INDEX IF NOT EXISTS centreline_midblocks_srid3857_geom ON centreline.midblocks USING GIST (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS centreline_midblocks_srid2952_geom ON centreline.midblocks USING GIST (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.midblocks;
