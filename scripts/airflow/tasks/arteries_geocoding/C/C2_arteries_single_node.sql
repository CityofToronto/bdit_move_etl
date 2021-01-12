CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_single_node AS (
  SELECT
    asl.arterycode,
    ncc."centrelineType",
    ncc."centrelineId",
    ncc.geom
  FROM counts.arteries_single_link asl
  JOIN counts.nodes_centreline ncc USING (link_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_single_node_arterycode ON counts.arteries_single_node (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_single_node;
