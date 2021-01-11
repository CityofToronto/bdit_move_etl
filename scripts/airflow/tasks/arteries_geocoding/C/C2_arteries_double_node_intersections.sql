CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_node_intersections AS (
  SELECT
    adl.arterycode,
    ncc_from."centrelineId" AS fnode,
    ncc_to."centrelineId" AS tnode,
    CASE
      WHEN ncc_from."centrelineType" IS NOT NULL AND ncc_to."centrelineType" IS NOT NULL THEN 2
      WHEN ncc_from."centrelineType" IS NOT NULL OR ncc_to."centrelineType" IS NOT NULL THEN 1
      ELSE 0
    END AS n,
    ST_LineInterpolatePoint(ST_MakeLine(ncc_from.geom, ncc_to.geom), 0.5) AS geom
  FROM counts2.arteries_double_link adl
  LEFT JOIN counts2.nodes_centreline ncc_from ON adl.from_link_id = ncc_from.link_id
  LEFT JOIN counts2.nodes_centreline ncc_to ON adl.to_link_id = ncc_to.link_id
  WHERE ncc_from."centrelineType" = 2
  AND ncc_to."centrelineType" = 2
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_node_intersections_arterycode ON counts2.arteries_double_node_intersections (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_node_intersections;
