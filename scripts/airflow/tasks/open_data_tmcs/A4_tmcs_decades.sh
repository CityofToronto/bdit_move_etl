#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

mkdir -p /data/open_data/tmcs

# get start and end years
# shellcheck disable=SC2046
YEAR_MIN=$(env $(xargs < /home/ec2-user/cot-env.config) psql -v ON_ERROR_STOP=1 -tAc "SELECT min(date_part('year', count_date)) from open_data.tmcs_count_metadata")
# shellcheck disable=SC2046
YEAR_MAX=$(env $(xargs < /home/ec2-user/cot-env.config) psql -v ON_ERROR_STOP=1 -tAc "SELECT max(date_part('year', count_date)) from open_data.tmcs_count_metadata")

# get start and end decades
DECADE_MIN=$(echo "$YEAR_MIN / 10 * 10" | bc)
DECADE_MAX=$(echo "$YEAR_MAX / 10 * 10" | bc)
for YEAR_START in $(seq $DECADE_MIN 10 $DECADE_MAX); do
  YEAR_END=$(echo "$YEAR_START + 9" | bc)
  echo "$YEAR_START - $YEAR_END"
  DECADE_FILEPATH="/data/open_data/tmcs/tmcs_${YEAR_START}_${YEAR_END}.csv"

  # shellcheck disable=SC2046
  env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 -v "yearStart=${YEAR_START}" -v "yearEnd=${YEAR_END}" -f "${TASKS_ROOT}/open_data_tmcs/download/download_tmcs_decade.sql" > "$DECADE_FILEPATH"
done
