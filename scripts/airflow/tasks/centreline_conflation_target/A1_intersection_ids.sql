CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.intersection_ids AS (
   WITH ids_raw AS (
    SELECT cmb.fnode AS "centrelineId"
    FROM centreline.midblocks_base cmb
    JOIN centreline.intersections_base cib ON cmb.fnode = cib."centrelineId"
    WHERE cmb."featureCode" <= 201803
    UNION ALL
    SELECT cmb.tnode AS "centrelineId"
    FROM centreline.midblocks_base cmb
    JOIN centreline.intersections_base cib ON cmb.tnode = cib."centrelineId"
    WHERE cmb."featureCode" <= 201803
  )
  SELECT DISTINCT("centrelineId")
  FROM ids_raw
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_intersection_ids_id ON centreline.intersection_ids ("centrelineId");

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.intersection_ids;
