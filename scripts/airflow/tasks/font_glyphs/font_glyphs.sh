#!/bin/bash

set -euo pipefail
GIT_ROOT=/home/ec2-user/move_etl
TASKS_ROOT="${GIT_ROOT}/scripts/airflow/tasks"

mkdir -p /data/fonts
cd /data/fonts
rm -rf fonts

git clone --depth=1 --branch=master https://github.com/openmaptiles/fonts.git
cd fonts
rm -rf .git
rm -r metropolis noto-sans open-sans pt-sans
npm install
node ./generate.js

cp -r _output/. /data/glyphs
