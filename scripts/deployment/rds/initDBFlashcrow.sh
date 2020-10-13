#!/bin/bash
#
# initDBFlashcrow.sh
#
# Call this before any installation scripts to ensure that the MOVE database
# (`flashcrow`) is set up.

set -e
set -o nounset

cd "$(dirname "$0")"
FLASHCROW_PASSWORD=$(openssl rand -base64 32)
psql -h "$PGHOST" postgres flashcrow_dba -v flashcrowPassword="$FLASHCROW_PASSWORD" -f ./createDBFlashcrow.sql
echo "${PGHOST}:5432:flashcrow:flashcrow:${FLASHCROW_PASSWORD}" >> /home/ec2-user/.pgpass

# shellcheck disable=SC2046
env $(xargs < "/home/ec2-user/cot-env.config") psql < ./collision_factors.sql
