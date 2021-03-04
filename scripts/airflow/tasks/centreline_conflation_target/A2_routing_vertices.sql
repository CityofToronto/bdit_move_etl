CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.routing_vertices AS (
  SELECT
    cib."centrelineId" AS id,
    ST_Transform(cib.geom, 2952) AS geom
  FROM centreline.intersections_base cib
  JOIN centreline.intersection_ids USING ("centrelineId")
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_routing_vertices_id ON centreline.routing_vertices (id);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.routing_vertices;
