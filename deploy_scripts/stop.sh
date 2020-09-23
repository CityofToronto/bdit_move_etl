#!/bin/bash

set -euo pipefail

set +u
source /home/ec2-user/.bash_profile
set -u

sudo systemctl stop airflow-scheduler
sudo systemctl stop airflow-webserver
