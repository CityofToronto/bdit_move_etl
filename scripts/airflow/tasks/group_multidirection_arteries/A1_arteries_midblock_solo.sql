CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_midblock_solo AS (
  WITH a AS (
    SELECT centreline_id
    FROM (
      SELECT centreline_id, COUNT(*) as n
      FROM counts.arteries_centreline
      WHERE centreline_type = 1 AND centreline_id IS NOT NULL
      GROUP BY centreline_id
    ) t
    WHERE n = 1
  )
  SELECT ac.arterycode, ac.centreline_type, ac.centreline_id, ac.geom
  FROM a
  JOIN counts.arteries_centreline ac USING (centreline_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_midblock_solo_arterycode1 ON counts.arteries_midblock_solo (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_midblock_solo;
