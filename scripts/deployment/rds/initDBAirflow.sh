#!/bin/bash
#
# initDBAirflow.sh
#
# Call this before any installation scripts to ensure that the Airflow database is set up.

set -euo pipefail

cd "$(dirname "$0")"
AIRFLOW_PASSWORD=$(openssl rand -base64 32)
psql -h "${PGHOST}" postgres flashcrow_dba -v airflowPassword="${AIRFLOW_PASSWORD}" -f ./createDBAirflow.sql
echo "${PGHOST}:5432:airflow:airflow:${AIRFLOW_PASSWORD}" >> /home/ec2-user/.pgpass
