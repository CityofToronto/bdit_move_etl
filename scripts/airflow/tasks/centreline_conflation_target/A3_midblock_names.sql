CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.midblock_names AS (
  SELECT
    cmb."centrelineId",
    cmb."midblockName",
    fci.description AS "fromIntersectionName",
    tci.description AS "toIntersectionName"
  FROM centreline.midblocks_base cmb
  LEFT JOIN centreline.intersections fci ON cmb.fnode = fci."centrelineId"
  LEFT JOIN centreline.intersections tci ON cmb.tnode = tci."centrelineId"
  WHERE cmb."featureCode" <= 201803
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_midblock_names_id ON centreline.midblock_names ("centrelineId");

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.midblock_names;
