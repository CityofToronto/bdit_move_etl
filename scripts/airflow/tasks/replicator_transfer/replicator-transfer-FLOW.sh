#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

"${TASKS_ROOT}/replicator_transfer/replicator-transfer.sh" --chunkSize 2000000 --config "FLOW" --emailsTo "move-ops@toronto.ca" --rowCountTolerance 0.05 --targetSchema "TRAFFIC" --targetValidationSchema "TRAFFIC_NEW"
