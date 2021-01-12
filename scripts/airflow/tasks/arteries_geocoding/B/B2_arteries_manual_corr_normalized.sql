CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_manual_corr_type1 AS (
  SELECT DISTINCT ON (arterycode, centreline_id)
    arterycode,
    centreline_id AS "centrelineId"
  FROM counts.arteries_manual_corr amc
  JOIN centreline.midblocks cm ON amc.centreline_id = cm."centrelineId"
  WHERE artery_type = 1
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_manual_corr_type1_arterycode ON counts.arteries_manual_corr_type1 (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_manual_corr_type1;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_manual_corr_type2 AS (
  WITH arterycode_endpoints AS (
    SELECT
      amc.arterycode,
      cm.fnode AS "centrelineId"
    FROM counts.arteries_manual_corr amc
    JOIN centreline.midblocks cm ON amc.centreline_id = cm."centrelineId"
    WHERE artery_type = 2
    UNION ALL
    SELECT
      amc.arterycode,
      cm.tnode AS "centrelineId"
    FROM counts.arteries_manual_corr amc
    JOIN centreline.midblocks cm ON amc.centreline_id = cm."centrelineId"
    WHERE artery_type = 2
  ),
  arterycode_candidates AS (
    -- The old conflation process only output midblocks, which meant that it had to represent
    -- intersections using all midblocks incident on that intersection.
    --
    -- Given a series of such `(arterycode, centrelineId)` pairs representing midblocks,
    -- this next part finds all intersections that are the endpoint of at least one such
    -- midblocks, then ranks them by how many midblocks they're an endpoint of.
    SELECT
      arterycode,
      "centrelineId",
      COUNT(*) AS score
    FROM arterycode_endpoints
    GROUP BY arterycode, "centrelineId"
    ORDER BY arterycode, "centrelineId"
  ),
  arterycode_ranking AS (
    SELECT
      arterycode,
      "centrelineId",
      score,
      row_number() OVER (PARTITION BY arterycode ORDER BY score DESC) AS ranking
    FROM arterycode_candidates
  )
  SELECT arterycode, "centrelineId"
  FROM arterycode_ranking
  WHERE ranking = 1
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_manual_corr_type2_arterycode ON counts.arteries_manual_corr_type2 (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_manual_corr_type2;
