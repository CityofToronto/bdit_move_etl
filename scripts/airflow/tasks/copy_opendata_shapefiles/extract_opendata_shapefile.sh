#!/bin/bash

set -euo pipefail

NAME="{{ params.name }}"
RESOURCE_URL="{{ params.resource_url }}"

SHAPEFILE_ZIP_PATH="/data/shapefile/${NAME}.zip"
SHAPEFILE_DIR="/data/shapefile/${NAME}"

mkdir -p /data/shapefile
curl "${RESOURCE_URL}" > "${SHAPEFILE_ZIP_PATH}"
rm -rf "${SHAPEFILE_DIR}"
unzip "${SHAPEFILE_ZIP_PATH}" -d "${SHAPEFILE_DIR}"
