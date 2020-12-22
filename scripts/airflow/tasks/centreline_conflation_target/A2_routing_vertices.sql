CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.routing_vertices AS (
  SELECT DISTINCT ON (gci.int_id)
    gci.int_id::int AS id,
    ST_Transform(gci.geom, 2952) AS geom
  FROM gis.centreline_intersection gci
  JOIN centreline.intersection_ids USING (int_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_routing_vertices_id ON centreline.routing_vertices (id);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.routing_vertices;
