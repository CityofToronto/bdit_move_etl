CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_node_midblocks AS (
  SELECT adni.arterycode, cm."centrelineId"
  FROM counts2.arteries_double_node_intersections adni
  JOIN centreline.midblocks cm ON (
    (adni.fnode = cm.fnode AND adni.tnode = cm.tnode)
    OR (adni.fnode = cm.tnode AND adni.tnode = cm.fnode)
  )
  WHERE adni.n = 2
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_node_midblocks_arterycode_centreline ON counts2.arteries_double_node_midblocks (arterycode, "centrelineId");

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_node_midblocks;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_node_midblocks_single AS (
  WITH candidate_counts AS (
    SELECT arterycode, count(*) AS n
    FROM counts2.arteries_double_node_midblocks
    GROUP BY arterycode
  )
  SELECT adnm.arterycode, adnm."centrelineId"
  FROM counts2.arteries_double_node_midblocks adnm
  JOIN candidate_counts cc USING (arterycode)
  WHERE cc.n = 1
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_node_midblocks_single_arterycode ON counts2.arteries_double_node_midblocks_single (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_node_midblocks_single;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_node_midblocks_multi AS (
   WITH candidate_counts AS (
    SELECT arterycode, count(*) AS n
    FROM counts2.arteries_double_node_midblocks
    GROUP BY arterycode
  )
  SELECT adnm.arterycode, adnm."centrelineId"
  FROM counts2.arteries_double_node_midblocks adnm
  JOIN candidate_counts cc USING (arterycode)
  WHERE cc.n > 1
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_node_midblocks_multi_arterycode_centreline ON counts2.arteries_double_node_midblocks_multi (arterycode, "centrelineId");

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_node_midblocks_multi;
