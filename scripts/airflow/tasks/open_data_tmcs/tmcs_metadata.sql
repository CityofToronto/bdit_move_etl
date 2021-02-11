CREATE SCHEMA IF NOT EXISTS open_data;

CREATE OR REPLACE VIEW open_data.tmcs_metadata AS (
  SELECT
    cim."COUNT_INFO_ID" AS count_info_id,
    cim."COUNT_DATE" AS count_date,
    cim."ARTERYCODE" AS location_id,
    ST_X(ac.geom) AS lng,
    ST_Y(ac.geom) AS lat,
    ac.centreline_type,
    ac.centreline_id,
    lsts.px AS traffic_signal_id,
    ad."LOCATION"
  FROM "TRAFFIC"."COUNTINFOMICS" cim
  JOIN "TRAFFIC"."ARTERYDATA" ad USING ("ARTERYCODE")
  JOIN counts.arteries_centreline ac ON cim."ARTERYCODE" = ac.arterycode
  LEFT JOIN location_search.traffic_signal lsts ON ac.centreline_type = lsts."centrelineType" AND ac.centreline_id = lsts."centrelineId"
  ORDER BY cim."COUNT_INFO_ID" ASC
);
