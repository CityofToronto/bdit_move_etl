CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.intersection_ids AS (
   WITH ids_raw AS (
    SELECT fnode AS "int_id"
    FROM gis.centreline gc
    JOIN gis.centreline_intersection gci ON gc.fnode = gci.int_id
    WHERE fcode <= 201803
    UNION ALL
    SELECT tnode AS "int_id"
    FROM gis.centreline gc
    JOIN gis.centreline_intersection gci ON gc.tnode = gci.int_id
    WHERE fcode <= 201803
  )
  SELECT DISTINCT(int_id)
  FROM ids_raw
);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.intersection_ids;
