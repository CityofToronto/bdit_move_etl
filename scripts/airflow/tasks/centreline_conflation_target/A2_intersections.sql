CREATE SCHEMA IF NOT EXISTS centreline;

CREATE MATERIALIZED VIEW IF NOT EXISTS centreline.intersections AS (
  SELECT
    cib."centrelineId",
    cib."centrelineType",
    cib."classification",
    cib."description",
    cib."featureCode",
    cib."geom",
    cib."lat",
    cib."lng"
  FROM centreline.intersections_base cib
  JOIN centreline.intersection_ids USING ("centrelineId")
  WHERE cib."featureCode" != 509200 OR cib."classification" != 'SEUML'
);
CREATE UNIQUE INDEX IF NOT EXISTS centreline_intersections_centreline ON centreline.intersections ("centrelineId");
CREATE INDEX IF NOT EXISTS centreline_intersections_geom ON centreline.intersections USING GIST (geom);
CREATE INDEX IF NOT EXISTS centreline_intersections_srid3857_geom ON centreline.intersections USING GIST (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS centreline_intersections_srid2952_geom ON centreline.intersections USING GIST (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY centreline.intersections;
