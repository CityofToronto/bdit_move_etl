CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.routing_edges AS (
  SELECT
    cm."centrelineId" AS id,
    cm.fnode AS source,
    cm.tnode AS target,
    ST_Length(ST_Transform(cm.geom, 2952)) AS cost,
    -1 AS reverse_cost,
    ST_X(vf.geom) AS x1,
    ST_Y(vf.geom) AS y1,
    ST_X(vt.geom) AS x2,
    ST_Y(vt.geom) AS y2
  FROM centreline.midblocks cm
  JOIN centreline.routing_vertices vf ON cm.fnode = vf.id
  JOIN centreline.routing_vertices vt ON cm.tnode = vt.id
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_routing_edges_id ON centreline.routing_edges (id);
CREATE INDEX IF NOT EXISTS centreline_routing_edges_source ON centreline.routing_edges (source);
CREATE INDEX IF NOT EXISTS centreline_routing_edges_target ON centreline.routing_edges (target);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.routing_edges;
