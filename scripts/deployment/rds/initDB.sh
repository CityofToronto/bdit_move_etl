#!/bin/bash
#
# initDB.sh
#
# This script is intended to be called after `deploy_scripts/start.sh`

set -e
set -o nounset

cd "$(dirname "$0")"
psql -h "$PGHOST" postgres flashcrow_dba -v flashcrowPassword="$FLASHCROW_PASSWORD" -v airflowPassword="$AIRFLOW_PASSWORD" -f ./createDB.sql

# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql < ./collision_factors.sql

# init Airflow database
airflow initdb

# add admin user
AIRFLOW_ADMIN_PASSWORD=$(openssl rand -base64 32)
python ./airflow_admin_user.py "${AIRFLOW_ADMIN_PASSWORD}"
echo "admin:${AIRFLOW_ADMIN_PASSWORD}"
