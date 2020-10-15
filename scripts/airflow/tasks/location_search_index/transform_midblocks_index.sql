CREATE SCHEMA IF NOT EXISTS location_search;

CREATE MATERIALIZED VIEW IF NOT EXISTS location_search.centreline AS (
  SELECT
    gc.geo_id,
    MODE() WITHIN GROUP (ORDER BY gc.lf_name) AS "midblockName",
    MODE() WITHIN GROUP (ORDER BY fgci.intersec5) AS "fromIntersectionName",
    MODE() WITHIN GROUP (ORDER BY tgci.intersec5) AS "toIntersectionName"
  FROM gis.centreline gc
  LEFT JOIN gis.centreline_intersection fgci ON gc.fnode = fgci.int_id
  LEFT JOIN gis.centreline_intersection tgci ON gc.tnode = tgci.int_id
  WHERE gc.fcode >= 201200 AND gc.fcode <= 201800
  AND fgci.elevatio9 >= 501200 AND fgci.elevatio9 <= 501700
  GROUP BY gc.geo_id
);

CREATE UNIQUE INDEX IF NOT EXISTS ls_centreline_geo_id ON location_search.centreline (geo_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY location_search.centreline;
