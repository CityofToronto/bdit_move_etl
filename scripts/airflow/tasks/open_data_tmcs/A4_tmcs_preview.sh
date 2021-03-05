#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 < "${TASKS_ROOT}/open_data_tmcs/A4_tmcs_preview.sql"

mkdir -p /data/open_data/tmcs
# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -v "view=open_data.tmcs_preview" -f "${TASKS_ROOT}/open_data_tmcs/download/download_view_as_csv.sql" > /data/open_data/tmcs/tmcs_preview.csv
