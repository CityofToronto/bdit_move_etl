CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_single_node AS (
  SELECT
    asl.arterycode,
    ncc."centrelineType",
    ncc."centrelineId",
    ncc.geom
  FROM counts2.arteries_single_link asl
  JOIN counts2.nodes_centreline ncc USING (link_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_single_node_arterycode ON counts2.arteries_single_node (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_single_node;
