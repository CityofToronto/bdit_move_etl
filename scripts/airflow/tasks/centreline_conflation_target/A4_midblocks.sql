CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.midblocks AS (
  SELECT
    va.aadt,
    cmb."centrelineId",
    cmb."centrelineType",
    cmb."featureCode",
    cmb."fnode",
    cmn."fromIntersectionName",
    cmb."geom",
    cmb."lat",
    cmb."lng",
    cmb."midblockName",
    cmb."roadId",
    cmb."tnode",
    cmn."toIntersectionName"
  FROM centreline.midblocks_base cmb
  LEFT JOIN centreline.midblock_names cmn USING ("centrelineId")
  LEFT JOIN volume.aadt va ON cmb."centrelineId" = va.centreline_id
  WHERE cmb."featureCode" <= 201803
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_midblocks_centreline ON centreline.midblocks ("centrelineId");
CREATE INDEX IF NOT EXISTS centreline_midblocks_fnode_tnode ON centreline.midblocks (fnode, tnode);
CREATE INDEX IF NOT EXISTS centreline_midblocks_geom ON centreline.midblocks USING GIST (geom);
CREATE INDEX IF NOT EXISTS centreline_midblocks_srid3857_geom ON centreline.midblocks USING GIST (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS centreline_midblocks_srid2952_geom ON centreline.midblocks USING GIST (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.midblocks;
