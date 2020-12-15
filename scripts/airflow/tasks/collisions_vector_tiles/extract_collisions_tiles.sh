#!/bin/bash

set -euo pipefail

rm -rf /data/tiles/collisionsLevel3:10
mb-util --image_format=pbf --silent /data/tiles/collisionsLevel3:10.mbtiles /data/tiles/collisionsLevel3:10

rm -rf /data/tiles/collisionsLevel2:10
mb-util --image_format=pbf --silent /data/tiles/collisionsLevel2:10.mbtiles /data/tiles/collisionsLevel2:10
