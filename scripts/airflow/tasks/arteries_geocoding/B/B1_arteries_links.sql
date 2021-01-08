CREATE SCHEMA IF NOT EXISTS counts2;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_single_link AS (
  SELECT
    "ARTERYCODE" AS arterycode,
    "LINKID"::bigint AS link_id
  FROM "TRAFFIC"."ARTERYDATA"
  WHERE "LINKID" NOT LIKE '%@%'
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_single_link_arterycode ON counts2.arteries_single_link (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_single_link;

CREATE MATERIALIZED VIEW IF NOT EXISTS counts2.arteries_double_link AS (
  SELECT
    "ARTERYCODE" AS arterycode,
    substring("LINKID", '([0-9]{1,20})@?')::bigint AS from_link_id,
    substring("LINKID", '@([0-9]{1,20})')::bigint AS to_link_id,
    "GEO_ID"::bigint AS geo_id
  FROM "TRAFFIC"."ARTERYDATA"
  WHERE "LINKID" LIKE '%@%'
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_double_link_arterycode ON counts2.arteries_double_link (arterycode);

REFRESH MATERIALIZED VIEW CONCURRENTLY counts2.arteries_double_link;
