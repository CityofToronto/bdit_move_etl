#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

mkdir -p /data/tiles
# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -v datesFromInterval="'10 year'" -f "${TASKS_ROOT}/collisions_vector_tiles/build_collisions_tiles/download_collisionsLevel3.sql" > /data/tiles/collisionsLevel3:10.json

# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -v datesFromInterval="'10 year'" -f "${TASKS_ROOT}/collisions_vector_tiles/build_collisions_tiles/download_collisionsLevel2.sql" > /data/tiles/collisionsLevel2:10.json

tippecanoe --progress-interval=10 --force -o /data/tiles/collisionsLevel3:10.mbtiles -l collisionsLevel3:10 -Z10 -z16 --accumulate-attribute=heatmap_weight:sum --cluster-densest-as-needed -r1 /data/tiles/collisionsLevel3:10.json

tippecanoe --progress-interval=10 --force -o /data/tiles/collisionsLevel2:10.mbtiles -l collisionsLevel2:10 -Z14 -z16 /data/tiles/collisionsLevel2:10.json
