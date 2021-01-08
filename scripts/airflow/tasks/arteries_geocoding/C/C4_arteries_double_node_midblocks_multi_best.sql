CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_node_midblocks_multi_best AS (
  WITH text_comparison AS (
    SELECT
      adnmm.arterycode,
      adnmm."centrelineId",
      CONCAT(ad."STREET1", ' ', ad."STREET1TYPE") AS street1,
      cm."midblockName"
    FROM counts2.arteries_double_node_midblocks_multi adnmm
    JOIN "TRAFFIC"."ARTERYDATA" ad ON adnmm.arterycode = ad."ARTERYCODE"
    JOIN centreline.midblocks cm USING ("centrelineId")
  ),
  arterycode_candidates AS (
    SELECT
      arterycode,
      "centrelineId",
      word_similarity(street1, "midblockName") AS score
    FROM text_comparison
  ),
  arterycode_ranking AS (
    SELECT
      arterycode,
      "centrelineId",
      score,
      row_number() OVER (PARTITION BY arterycode ORDER BY score DESC) AS ranking
    FROM arterycode_candidates
  )
  SELECT arterycode, "centrelineId", score
  FROM arterycode_ranking
  WHERE ranking = 1 AND score > 0.2
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_node_midblocks_multi_best_arterycode ON counts2.arteries_double_node_midblocks_multi_best (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_node_midblocks_multi_best;
