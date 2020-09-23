#!/bin/bash
# shellcheck disable=SC1090,SC1091

set -euo pipefail

set +u
source /home/ec2-user/.bash_profile
set -u

# copy airflow.cfg over
cp /home/ec2-user/move_etl/scripts/deployment/etl/airflow.cfg /home/ec2-user/airflow/airflow.cfg

# copy nginx configs from repo
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/nginx/default.d/*.conf /etc/nginx/default.d/

# copy logrotate files from repo
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/logrotate/logrotate.conf /etc/logrotate.conf
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/logrotate/logrotate.d/* /etc/logrotate.d/

# copy systemd files from repo
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/systemd/airflow /etc/sysconfig/airflow
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/systemd/airflow.conf /usr/lib/tmpfiles.d/
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/systemd/airflow-scheduler.service /usr/lib/systemd/system/
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/systemd/airflow-webserver.service /usr/lib/systemd/system/
sudo cp /home/ec2-user/move_etl/scripts/deployment/etl/systemd/journald.conf /etc/systemd/journald.conf

# install dependencies
cd /home/ec2-user/flashcrow
pip install -r requirements.txt

# upgrade Airflow database to latest schema
airflow upgradedb

# need to restart nginx
sudo service nginx restart

# start services
sudo systemctl start airflow-webserver
sudo systemctl start airflow-scheduler
