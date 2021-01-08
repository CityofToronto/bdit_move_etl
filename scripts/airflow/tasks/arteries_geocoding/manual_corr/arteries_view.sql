CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_manual_corr AS
  SELECT * FROM counts2_new.arteries_manual_corr;

CREATE UNIQUE INDEX IF NOT EXISTS arteries_manual_corr_arterycode_direction_sideofint ON counts2.arteries_manual_corr (arterycode, direction, sideofint);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_manual_corr;
