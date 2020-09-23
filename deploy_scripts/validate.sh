#!/bin/bash
# shellcheck disable=SC1091

set -euo pipefail

sudo systemctl status airflow-webserver
sudo systemctl status airflow-scheduler
