#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql -v ON_ERROR_STOP=1 < "${TASKS_ROOT}/crash_geocoding/A4_involved.sql"
