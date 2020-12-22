CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.midblock_names AS (
  SELECT
    gc.geo_id,
    MODE() WITHIN GROUP (ORDER BY gc.lf_name) AS "midblockName",
    MODE() WITHIN GROUP (ORDER BY fci.description) AS "fromIntersectionName",
    MODE() WITHIN GROUP (ORDER BY tci.description) AS "toIntersectionName"
  FROM gis.centreline gc
  LEFT JOIN centreline.intersections fci ON gc.fnode = fci."centrelineId"
  LEFT JOIN centreline.intersections tci ON gc.tnode = tci."centrelineId"
  WHERE gc.fcode <= 201803
  GROUP BY gc.geo_id
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_midblock_names_geo_id ON centreline.midblock_names (geo_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.midblock_names;
