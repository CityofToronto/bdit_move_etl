CREATE SCHEMA IF NOT EXISTS counts2;
CREATE SCHEMA IF NOT EXISTS counts2_new;

CREATE TABLE IF NOT EXISTS counts2_new.nodes_centreline (
  link_id BIGINT NOT NULL,
  match_on_case SMALLINT NOT NULL,
  "centrelineType" INT,
  "centrelineId" INT,
  geom GEOMETRY(POINT, 4326) NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS nodes_centreline_link_id ON counts2_new.nodes_centreline (link_id);

TRUNCATE TABLE counts2_new.nodes_centreline;

-- Case 1: corrected node geometry has close spatial match (10m) to intersection geometry
INSERT INTO counts2_new.nodes_centreline (
  SELECT
    ncor.link_id,
    1 AS match_on_case,
    ci."centrelineType",
    ci."centrelineId",
    ncor.geom
  FROM counts2.nodes_corrected ncor
  JOIN LATERAL (
    SELECT
      "centrelineType",
      "centrelineId",
      ST_Distance(ST_Transform(ncor.geom, 2952), ST_Transform(geom, 2952)) AS geom_dist
    FROM centreline.intersections
    WHERE ST_DWithin(ST_Transform(ncor.geom, 2952), ST_Transform(geom, 2952), 10)
    ORDER BY geom_dist ASC
    LIMIT 1
  ) ci ON true
);

-- Case 2: corrected node geometry has close spatial match (10m) to midblock geometry
INSERT INTO counts2_new.nodes_centreline (
  SELECT
    ncor.link_id,
    2 AS match_on_case,
    cm."centrelineType",
    cm."centrelineId",
    ncor.geom
  FROM counts2.nodes_corrected ncor
  LEFT JOIN counts2_new.nodes_centreline ncen USING (link_id)
  JOIN LATERAL (
    SELECT
      "centrelineType",
      "centrelineId",
      ST_Distance(ST_Transform(ncor.geom, 2952), ST_Transform(geom, 2952)) AS geom_dist
    FROM centreline.midblocks
    WHERE ST_DWithin(ST_Transform(ncor.geom, 2952), ST_Transform(geom, 2952), 10)
    ORDER BY geom_dist ASC
    LIMIT 1
  ) cm ON true
  WHERE ncen.link_id IS NULL
);

-- Case 3: node link ID matches intersection ID
INSERT INTO counts2_new.nodes_centreline (
  SELECT
    ncor.link_id,
    3 AS match_on_case,
    ci."centrelineType",
    ci."centrelineId",
    ncor.geom
  FROM counts2.nodes_corrected ncor
  LEFT JOIN counts2_new.nodes_centreline ncen USING (link_id)
  JOIN centreline.intersections ci ON ncor.link_id = ci."centrelineId"
  WHERE ncen.link_id IS NULL
);

-- Case 4: node link ID matches midblock ID
INSERT INTO counts2_new.nodes_centreline (
  SELECT
    ncor.link_id,
    4 AS match_on_case,
    cm."centrelineType",
    cm."centrelineId",
    ncor.geom
  FROM counts2.nodes_corrected ncor
  LEFT JOIN counts2_new.nodes_centreline ncen USING (link_id)
  JOIN centreline.midblocks cm ON ncor.link_id = cm."centrelineId"
  WHERE ncen.link_id IS NULL
);

-- Case 5: fail to match
INSERT INTO counts2_new.nodes_centreline (
  SELECT
    ncor.link_id,
    5 AS match_on_case,
    NULL AS "centrelineType",
    NULL AS "centrelineId",
    ncor.geom
  FROM counts2.nodes_corrected ncor
  LEFT JOIN counts2_new.nodes_centreline ncen USING (link_id)
  WHERE ncen.link_id IS NULL
);

-- Update double-buffered view.
CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.nodes_centreline AS
  SELECT * FROM counts2_new.nodes_centreline;
CREATE UNIQUE INDEX IF NOT EXISTS nodes_centreline_link_id ON counts2.nodes_centreline (link_id);
CREATE INDEX IF NOT EXISTS nodes_centreline_srid2952_geom ON counts2.nodes_centreline USING gist (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.nodes_centreline;
