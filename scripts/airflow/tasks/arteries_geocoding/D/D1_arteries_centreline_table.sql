CREATE SCHEMA IF NOT EXISTS counts_new;

CREATE TABLE IF NOT EXISTS counts_new.arteries_centreline (
  arterycode BIGINT NOT NULL,
  match_on_case SMALLINT NOT NULL,
  "centrelineType" INT,
  "centrelineId" INT,
  geom GEOMETRY(POINT, 4326)
);
CREATE UNIQUE INDEX IF NOT EXISTS arteries_centreline_arterycode ON counts_new.arteries_centreline (arterycode);

TRUNCATE TABLE counts_new.arteries_centreline;

-- Case 1: traffic signals
INSERT INTO counts_new.arteries_centreline (
  SELECT
    apc.arterycode,
    1 AS match_on_case,
    apc."centrelineType",
    apc."centrelineId",
    apc.geom
  FROM counts.arteries_px_centreline apc
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

-- Case 2: manual correction
INSERT INTO counts_new.arteries_centreline (
  SELECT
    amct1.arterycode,
    2 AS match_on_case,
    1 AS "centrelineType",
    amct1."centrelineId",
    ST_Transform(ST_ClosestPoint(
      ST_Transform(cm.geom, 2952),
      ST_Transform(ST_Centroid(cm.geom), 2952)
    ), 4326) as geom
  FROM counts.arteries_manual_corr_type1 amct1
  JOIN centreline.midblocks cm USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

INSERT INTO counts_new.arteries_centreline (
  SELECT
    amct2.arterycode,
    2 AS match_on_case,
    2 AS "centrelineType",
    amct2."centrelineId",
    ci.geom as geom
  FROM counts.arteries_manual_corr_type2 amct2
  JOIN centreline.intersections ci USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

-- Case 3: single-link node match
INSERT INTO counts_new.arteries_centreline (
  SELECT
    asn.arterycode,
    3 AS match_on_case,
    asn."centrelineType",
    asn."centrelineId",
    ST_Transform(ST_ClosestPoint(
      ST_Transform(cm.geom, 2952),
      ST_Transform(ST_Centroid(cm.geom), 2952)
    ), 4326) as geom
  FROM counts.arteries_single_node asn
  JOIN centreline.midblocks cm USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE asn."centrelineType" = 1 AND ac.arterycode IS NULL
);

INSERT INTO counts_new.arteries_centreline (
  SELECT
    asn.arterycode,
    3 AS match_on_case,
    asn."centrelineType",
    asn."centrelineId",
    ci.geom
  FROM counts.arteries_single_node asn
  JOIN centreline.intersections ci USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE asn."centrelineType" = 2 AND ac.arterycode IS NULL
);

-- Case 4: double-link midblock match, single-candidate
INSERT INTO counts_new.arteries_centreline (
  SELECT
    adnms.arterycode,
    4 AS match_on_case,
    1 AS "centrelineType",
    adnms."centrelineId",
    ST_Transform(ST_ClosestPoint(
      ST_Transform(cm.geom, 2952),
      ST_Transform(ST_Centroid(cm.geom), 2952)
    ), 4326) as geom
  FROM counts.arteries_double_node_midblocks_single adnms
  JOIN centreline.midblocks cm USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

-- Case 5: double-link midblock match, multi-candidate
INSERT INTO counts_new.arteries_centreline (
  SELECT
    adnmmb.arterycode,
    5 AS match_on_case,
    1 AS "centrelineType",
    adnmmb."centrelineId",
    ST_Transform(ST_ClosestPoint(
      ST_Transform(cm.geom, 2952),
      ST_Transform(ST_Centroid(cm.geom), 2952)
    ), 4326) as geom
  FROM counts.arteries_double_node_midblocks_multi_best adnmmb
  JOIN centreline.midblocks cm USING ("centrelineId")
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

-- Case 6: double-link geo ID match
INSERT INTO counts_new.arteries_centreline (
  SELECT
    adl.arterycode,
    6 AS match_on_case,
    1 AS "centrelineType",
    cm."centrelineId",
    ST_Transform(ST_ClosestPoint(
      ST_Transform(cm.geom, 2952),
      ST_Transform(ST_Centroid(cm.geom), 2952)
    ), 4326) as geom
  FROM counts.arteries_double_link adl
  JOIN centreline.midblocks cm ON adl.geo_id = cm."centrelineId"
  LEFT JOIN counts_new.arteries_centreline am USING (arterycode)
  WHERE am.arterycode IS NULL
);

-- Case 7: no centreline conflation, but we have a location
INSERT INTO counts_new.arteries_centreline (
  SELECT
    asl.arterycode,
    7 AS match_on_case,
    NULL AS "centrelineType",
    NULL AS "centrelineId",
    ncc.geom
  FROM counts.arteries_single_link asl
  JOIN counts.nodes_centreline ncc USING (link_id)
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

INSERT INTO counts_new.arteries_centreline (
  SELECT
    adni.arterycode,
    7 AS match_on_case,
    NULL AS "centrelineType",
    NULL AS "centrelineId",
    adni.geom
  FROM counts.arteries_double_node_intersections adni
  LEFT JOIN counts_new.arteries_centreline ac USING (arterycode)
  WHERE ac.arterycode IS NULL
);

-- Case 8: no centreline conflation or location (i.e. failed)
INSERT INTO counts_new.arteries_centreline (
  SELECT
    ad."ARTERYCODE" AS arterycode,
    8 AS match_on_case,
    NULL AS centreline_type,
    NULL AS centreline_id,
    NULL AS geom
  FROM "TRAFFIC"."ARTERYDATA" ad
  LEFT JOIN counts_new.arteries_centreline ac ON ad."ARTERYCODE" = ac.arterycode
  WHERE ac.arterycode IS NULL
);
