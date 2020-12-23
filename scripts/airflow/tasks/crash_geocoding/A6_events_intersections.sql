CREATE SCHEMA IF NOT EXISTS collisions;

CREATE MATERIALIZED VIEW IF NOT EXISTS collisions.events_intersections AS (
	SELECT e.collision_id, u."centrelineId" FROM
		(SELECT collision_id, latitude, longitude FROM collisions.events) e
	  INNER JOIN LATERAL
		(SELECT "centrelineId", ST_Distance(
			ST_Transform(geom, 2952),
			ST_Transform(ST_SetSRID(ST_MakePoint(e.longitude, e.latitude), 4326), 2952)
	  ) AS geom_dist
		FROM centreline.intersections
		WHERE ST_DWithin(
      ST_Transform(geom, 2952),
      ST_Transform(ST_SetSRID(ST_MakePoint(e.longitude, e.latitude), 4326), 2952),
      30
    )
	  ORDER BY geom_dist ASC
	  LIMIT 1
	) u ON true
);
CREATE UNIQUE INDEX IF NOT EXISTS events_intersections_collision_id ON collisions.events_intersections (collision_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY collisions.events_intersections;
