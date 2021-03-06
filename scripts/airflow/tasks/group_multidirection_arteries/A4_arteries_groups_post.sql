-- Case 5: remaining arterycodes as singles
INSERT INTO counts_new.arteries_groups (
  SELECT
    ac.arterycode,
    5 AS match_on_case,
    ac.arterycode AS group_id,
    ac.centreline_type,
    ac.centreline_id,
    ac.geom
  FROM counts.arteries_centreline ac
  LEFT JOIN counts_new.arteries_groups ag USING (arterycode)
  WHERE ac.centreline_type IS NOT NULL AND ac.centreline_id IS NOT NULL
  AND ag.arterycode IS NULL
);

-- Update double-buffered view.
CREATE MATERIALIZED VIEW IF NOT EXISTS counts.arteries_groups AS
  SELECT * FROM counts_new.arteries_groups;
CREATE UNIQUE INDEX IF NOT EXISTS arteries_groups_arterycode ON counts.arteries_groups (arterycode);
CREATE INDEX IF NOT EXISTS arteries_groups_group_id ON counts.arteries_groups (group_id);
CREATE INDEX IF NOT EXISTS arteries_groups_centreline ON counts.arteries_groups (centreline_type, centreline_id);
CREATE INDEX IF NOT EXISTS arteries_groups_geom ON counts.arteries_groups USING GIST (geom);
CREATE INDEX IF NOT EXISTS arteries_groups_srid3857_geom ON counts.arteries_groups USING GIST (ST_Transform(geom, 3857));
CREATE INDEX IF NOT EXISTS arteries_groups_srid2952_geom ON counts.arteries_groups USING GIST (ST_Transform(geom, 2952));

REFRESH MATERIALIZED VIEW CONCURRENTLY counts.arteries_groups;
