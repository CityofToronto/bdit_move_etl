CREATE SCHEMA IF NOT EXISTS counts;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_centreline AS (
  SELECT
    ac.arterycode,
    ac."centrelineType" AS centreline_type,
    ac."centrelineId" AS centreline_id,
    CASE
      WHEN ac."centrelineType" = 1 THEN ad."APPRDIR"::CHAR(1)
      ELSE NULL::CHAR(1)
    END AS direction,
    ac.geom
  FROM counts_new.arteries_centreline ac
  JOIN "TRAFFIC"."ARTERYDATA" ad ON ac.arterycode = ad."ARTERYCODE"
);

CREATE UNIQUE INDEX IF NOT EXISTS arteries_centreline_arterycode ON counts.arteries_centreline (arterycode);
CREATE INDEX IF NOT EXISTS arteries_centreline_centreline ON counts.arteries_centreline (centreline_type, centreline_id);
CREATE INDEX IF NOT EXISTS arteries_centreline_geom ON counts.arteries_centreline using gist (geom);
CREATE INDEX IF NOT EXISTS arteries_centreline_srid3857_geom ON counts.arteries_centreline using gist (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS arteries_centreline_srid2952_geom ON counts.arteries_centreline using gist (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_centreline;
