#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

mkdir -p /data/arteries_geocoding
python "${TASKS_ROOT}/arteries_geocoding/D/D2_artery_geocoding.py" > "/data/arteries_geocoding/D2_artery_geocoding.sql"
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 < "/data/arteries_geocoding/D2_artery_geocoding.sql"
