#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"
FLASHCROW_DEV_DATA=/data/dev_data/flashcrow-dev-data.sql

mkdir -p /data/dev_data
{
  #
  # create required schemas
  #
  cat "${TASKS_ROOT}/dev_data/create_schemas.sql"

  #
  # copy schemas for unsampled tables
  #

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.intersections_base -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.midblocks_base -x --no-owner --clean --if-exists --schema-only

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t location_search.traffic_signal -x --no-owner --clean --if-exists --schema-only

  #
  # copy data for unsampled tables
  #

  echo 'COPY centreline.intersections_base FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM centreline.intersections_base) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY centreline.midblocks_base FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM centreline.midblocks_base) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY location_search.traffic_signal FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM location_search.traffic_signal) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  #
  # copy schemas for unsampled views
  #

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.counts_arteries_centreline -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.counts_arteries_centreline/counts.arteries_centreline/g"

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.gis_hospital -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.gis_hospital/gis.hospital/g"
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.gis_school -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.gis_school/gis.school/g"

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_category -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_category/"TRAFFIC"."CATEGORY"/g'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_arterydata -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_arterydata/"TRAFFIC"."ARTERYDATA"/g'

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.volume_aadt -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.volume_aadt/volume.aadt/g'

  #
  # copy data for unsampled views
  #

  echo 'COPY counts.arteries_centreline FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM counts.arteries_centreline) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY gis.hospital FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM gis.hospital) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY gis.school FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM gis.school) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY "TRAFFIC"."CATEGORY" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM \"TRAFFIC\".\"CATEGORY\") TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY "TRAFFIC"."ARTERYDATA" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM \"TRAFFIC\".\"ARTERYDATA\") TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY volume.aadt FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM volume.aadt) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  #
  # copy schemas for sampled tables / views
  #

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.collisions_events -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.collisions_events/collisions.events/g"
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.collisions_events_centreline -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.collisions_events_centreline/collisions.events_centreline/g"
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.collisions_involved -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.collisions_involved/collisions.involved/g"

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.counts_arteries_groups -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.counts_arteries_groups/counts.arteries_groups/g"
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.counts_counts_multiday_runs -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.counts_counts_multiday_runs/counts.counts_multiday_runs/g"
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.counts_studies -x --no-owner --clean --if-exists --schema-only | sed "s/flashcrow_dev_data.counts_studies/counts.studies/g"

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_countinfomics -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_countinfomics/"TRAFFIC"."COUNTINFOMICS"/g'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_det -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_det/"TRAFFIC"."DET"/g'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_countinfo -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_countinfo/"TRAFFIC"."COUNTINFO"/g'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t flashcrow_dev_data.traffic_cnt_det -x --no-owner --clean --if-exists --schema-only | sed 's/flashcrow_dev_data.traffic_cnt_det/"TRAFFIC"."CNT_DET"/g'

  #
  # copy data for sampled tables / views
  #

  echo 'COPY collisions.events FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.collisions_events) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY collisions.events_centreline FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.collisions_events_centreline) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY collisions.involved FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.collisions_involved) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY counts.arteries_groups FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.counts_arteries_groups) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY counts.counts_multiday_runs FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.counts_counts_multiday_runs) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY counts.studies FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.counts_studies) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  echo 'COPY "TRAFFIC"."COUNTINFOMICS" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.traffic_countinfomics) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY "TRAFFIC"."DET" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.traffic_det) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY "TRAFFIC"."COUNTINFO" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.traffic_countinfo) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'
  echo 'COPY "TRAFFIC"."CNT_DET" FROM stdin;'
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -c "COPY (SELECT * FROM flashcrow_dev_data.traffic_cnt_det) TO stdout (FORMAT text, ENCODING 'UTF-8')"
  echo '\.'

  #
  # copy view definitions where appropriate
  #

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.intersection_ids -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.intersections -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.midblock_names -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.midblocks -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.routing_vertices -x --no-owner --clean --if-exists --schema-only
  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t centreline.routing_edges -x --no-owner --clean --if-exists --schema-only


  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") pg_dump -t location_search.intersections -x --no-owner --clean --if-exists --schema-only

  #
  # refresh data for view definitions
  #
  echo 'REFRESH MATERIALIZED VIEW centreline.intersection_ids;'
  echo 'REFRESH MATERIALIZED VIEW centreline.intersections;'
  echo 'REFRESH MATERIALIZED VIEW centreline.midblock_names;'
  echo 'REFRESH MATERIALIZED VIEW centreline.midblocks;'
  echo 'REFRESH MATERIALIZED VIEW centreline.routing_vertices;'
  echo 'REFRESH MATERIALIZED VIEW centreline.routing_edges;'

  echo 'REFRESH MATERIALIZED VIEW location_search.intersections;'
} > "${FLASHCROW_DEV_DATA}"

# compress to reduce copying bandwidth
tar czvf "${FLASHCROW_DEV_DATA}.tar.gz" "${FLASHCROW_DEV_DATA}"
