CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.routing_vertices AS (
  WITH pseudo_vertex_ids AS (
    SELECT DISTINCT ("centrelineId") FROM (
      SELECT cm.fnode AS "centrelineId"
      FROM centreline.midblocks cm
      LEFT JOIN centreline.intersections_base cibf ON cm.fnode = cibf."centrelineId"
      WHERE cibf."centrelineId" IS NULL
      UNION ALL
      SELECT cm.tnode AS "centrelineId"
      FROM centreline.midblocks cm
      LEFT JOIN centreline.intersections_base cibt ON cm.tnode = cibt."centrelineId"
      WHERE cibt."centrelineId" IS NULL
    ) t
  ), pseudo_vertex_geom AS (
    SELECT
      pvi."centrelineId",
      ST_Centroid(ST_Collect(cm.geom)) AS geom
    FROM pseudo_vertex_ids pvi
    JOIN LATERAL (
      SELECT ST_Transform(geom, 2952) AS geom
      FROM centreline.midblocks cm
      WHERE cm.fnode = pvi."centrelineId" OR cm.tnode = pvi."centrelineId"
    ) cm ON true
    GROUP BY pvi."centrelineId"
  )
  SELECT
    cib."centrelineId" AS id,
    ST_Transform(cib.geom, 2952) AS geom
  FROM centreline.intersections_base cib
  JOIN centreline.intersection_ids USING ("centrelineId")
  UNION ALL
  SELECT "centrelineId" AS id, geom
  FROM pseudo_vertex_geom
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_routing_vertices_id ON centreline.routing_vertices (id);

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.routing_vertices;
