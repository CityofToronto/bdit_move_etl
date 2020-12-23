CREATE SCHEMA IF NOT EXISTS location_search;

CREATE MATERIALIZED VIEW IF NOT EXISTS location_search.intersections AS (
  SELECT "centrelineId", "description", "featureCode"
  FROM centreline.intersections
  WHERE
    "description" IS NOT NULL AND "description" LIKE '%/%'
    AND "featureCode" != 0 AND "featureCode" < 501700
);

CREATE UNIQUE INDEX IF NOT EXISTS ls_intersections_centreline ON location_search.intersections ("centrelineId");
CREATE INDEX IF NOT EXISTS ls_intersections_tsvector_description ON location_search.intersections USING GIN (to_tsvector('english', "description"));
CREATE INDEX IF NOT EXISTS ls_intersections_trgm_description ON location_search.intersections USING GIN ("description" gin_trgm_ops);

REFRESH MATERIALIZED VIEW CONCURRENTLY location_search.intersections;
