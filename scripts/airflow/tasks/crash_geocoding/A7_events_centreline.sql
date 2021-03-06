CREATE SCHEMA IF NOT EXISTS collisions;

CREATE MATERIALIZED VIEW IF NOT EXISTS collisions.events_centreline AS (
	SELECT
		e.collision_id,
	  CASE
	    WHEN ei."centrelineId" IS NOT NULL THEN 2
	    WHEN es."centrelineId" IS NOT NULL THEN 1
	  END as centreline_type,
	  COALESCE(ei."centrelineId", es."centrelineId") AS centreline_id
	FROM collisions.events e
	LEFT JOIN collisions.events_intersections ei ON e.collision_id = ei.collision_id
	LEFT JOIN collisions.events_segments es ON e.collision_id = es.collision_id
);
CREATE UNIQUE INDEX IF NOT EXISTS events_centreline_collision_id ON collisions.events_centreline (collision_id);
CREATE INDEX IF NOT EXISTS events_centreline_centreline ON collisions.events_centreline (centreline_type, centreline_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY collisions.events_centreline;
