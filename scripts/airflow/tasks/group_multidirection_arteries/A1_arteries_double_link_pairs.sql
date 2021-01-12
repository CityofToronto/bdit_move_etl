CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_double_link_pairs AS (
  WITH a AS (
    SELECT
      adl1.arterycode AS arterycode1,
      adl2.arterycode AS arterycode2,
      LEAST(adl1.from_link_id, adl1.to_link_id) AS from_link_id,
      GREATEST(adl1.from_link_id, adl1.to_link_id) AS to_link_id,
      ac1.centreline_type,
      ac1.centreline_id,
      ac1.geom AS geom
    FROM counts.arteries_double_link adl1
    JOIN counts.arteries_centreline ac1 ON adl1.arterycode = ac1.arterycode
    JOIN counts.arteries_double_link adl2 ON adl1.from_link_id = adl2.to_link_id AND adl1.to_link_id = adl2.from_link_id
    JOIN counts.arteries_centreline ac2 ON adl2.arterycode = ac2.arterycode
    WHERE adl1.arterycode < adl2.arterycode
    AND ac1.centreline_type = 1
    AND ac2.centreline_type = 1
    AND ac1.centreline_id = ac2.centreline_id
  ), b AS (
    SELECT from_link_id, to_link_id, COUNT(*) AS n
    FROM a
    GROUP BY from_link_id, to_link_id
  )
  SELECT
    a.arterycode1,
    a.arterycode2,
    a.centreline_type,
    a.centreline_id,
    a.geom
  FROM a
  JOIN b USING (from_link_id, to_link_id)
  WHERE b.n = 1
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_link_pairs_arterycode1 ON counts.arteries_double_link_pairs (arterycode1);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_double_link_pairs;
