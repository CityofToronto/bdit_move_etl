#!/bin/bash
#
# replicator-transfer.sh \
#   --config CONFIG \
#   --emailsTo EMAILS_TO \
#   --rowCountTolerance ROW_COUNT_TOLERANCE \
#   --targetSchema TARGET_SCHEMA \
#   --targetValidationSchema TARGET_VALIDATION_SCHEMA
#
# Finishes the replication job with configuration profile $CONFIG,
# using $TARGET_VALIDATION_SCHEMA in the database to validate before running
# ALTER TABLE ... SET SCHEMA $TARGET_SCHEMA to quickly cut over to the new
# data.  With this strategy, we can verify the data before it goes live, and
# effective downtime is on the order of seconds even for the largest tables.
#
# For validation, we check that the final PostgreSQL row count is within a factor
# of $ROW_COUNT_TOLERANCE of the original Oracle row count.  For instance,
# $ROW_COUNT_TOLERANCE of 0.001 will expect no more than 0.1% deviation from the
# original count.  This helps us verify that data arrived intact, while still
# leaving some leeway for INSERT / DELETE queries that were executed against
# Oracle during the migration.
#
# This is invoked on EC2 by replicator-local.ps1 via ssh, after that script has
# built the data tarball and copied it over to EC2.
#
# Note that we have disabled SC2086 (double-quotes around arguments) in several
# places, as we are intentionally expanding $PSQL_ARGS into separate arguments.

set -e
set -o nounset

CHUNK_SIZE=
CONFIG=
declare -a EMAILS_TO
ROW_COUNT_TOLERANCE=
TARGET_SCHEMA=
TARGET_VALIDATION_SCHEMA=

function parse_args {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --chunkSize )
      CHUNK_SIZE="$2"
      shift
      ;;
      --config )
      CONFIG="$2"
      shift
      ;;
      --emailsTo )
      EMAILS_TO+=("$2")
      shift
      ;;
      --rowCountTolerance )
      ROW_COUNT_TOLERANCE="$2"
      shift
      ;;
      --targetSchema )
      TARGET_SCHEMA="$2"
      shift
      ;;
      --targetValidationSchema )
      TARGET_VALIDATION_SCHEMA="$2"
      shift
      ;;
      * )
      echo "Invalid argument $1!"
      exit 1
      ;;
    esac
    shift
  done

  if [[ -z "$CHUNK_SIZE" ]]; then
    echo "Chunk size required!"
    exit 1
  fi
  if [[ -z "$CONFIG" ]]; then
    echo "Config file required!"
    exit 1
  fi
  if [[ -z "$ROW_COUNT_TOLERANCE" ]]; then
    echo "Row count tolerance required!"
    exit 1
  fi
  if [[ -z "$TARGET_SCHEMA" ]]; then
    echo "Target schema required!"
    exit 1
  fi
  if [[ -z "$TARGET_VALIDATION_SCHEMA" ]]; then
    echo "Target validation schema required!"
    exit 1
  fi
}

parse_args "$@"

# paths to important folders / files
DIR_ROOT="/data/replicator/flashcrow-$CONFIG"
DIR_ORA_CNT="$DIR_ROOT/ora_cnt"
DIR_PG="$DIR_ROOT/pg"
DIR_DAT="$DIR_ROOT/dat"
DIR_DAT_SPLIT="$DIR_ROOT/dat_split"
CONFIG_FILE="/data/replicator/$CONFIG.config.json"

# email settings
EMAIL_FROM="Flashcrow Replicator <replicator@flashcrow-etl.intra.dev-toronto.ca>"
EMAIL_SUBJECT_STATUS="[flashcrow] [replicator] Replication Status: $CONFIG"
EMAIL_SUBJECT_ERROR="[flashcrow] [replicator] Replication Error: $CONFIG"
EMAIL_SUBJECT_SUCCESS="[flashcrow] [replicator] Replication Success: $CONFIG"

# squelch NOTICEs from psql
export PGOPTIONS="--client-min-messages=warning"

function sendStatus {
  local -r MESSAGE="$1"
  local -r NOW=$(TZ='America/Toronto' date +"%Y-%m-%dT%H:%M:%S")
  for emailTo in "${EMAILS_TO[@]}"; do
    echo "$MESSAGE" | mail -r "$EMAIL_FROM" -s "$EMAIL_SUBJECT_STATUS" "$emailTo"
  done
  echo "$NOW $MESSAGE"
}

function sendStatusEmailDisable {
  local -r MESSAGE="$1"
  local -r NOW=$(TZ='America/Toronto' date +"%Y-%m-%dT%H:%M:%S")
  echo "$NOW $MESSAGE"
}

function exitError {
  local -r MESSAGE="$1"
  local -r NOW=$(TZ='America/Toronto' date +"%Y-%m-%dT%H:%M:%S")
  for emailTo in "${EMAILS_TO[@]}"; do
    echo "$MESSAGE" | mail -r "$EMAIL_FROM" -s "$EMAIL_SUBJECT_ERROR" "$emailTo"
  done
  (>&2 echo "$NOW $MESSAGE")
  exit 1
}

function exitSuccess {
  local -r MESSAGE="$1"
  local -r NOW=$(TZ='America/Toronto' date +"%Y-%m-%dT%H:%M:%S")
  for emailTo in "${EMAILS_TO[@]}"; do
    echo "$MESSAGE" | mail -r "$EMAIL_FROM" -s "$EMAIL_SUBJECT_SUCCESS" "$emailTo"
  done
  echo "$NOW $MESSAGE"
  exit 0
}

sendStatus "Starting remote PostgreSQL data transfer..."

# unpack data files
cd "$HOME"
# shellcheck disable=SC2038
find "$DIR_DAT" -name "*.gz" | xargs gunzip -f
sendStatusEmailDisable "Unpacked data on transfer machine..."

# split data files into chunks
rm -rf "$DIR_DAT_SPLIT"
mkdir -p "$DIR_DAT_SPLIT"
# shellcheck disable=SC2086
jq -r ".tables[].name" "$CONFIG_FILE" | while read -r table; do
  DAT_FILE="$DIR_DAT/$table.dat"
  DAT_SPLIT_PREFIX="$DIR_DAT_SPLIT/$table.dat."
  split --verbose --numeric-suffixes --suffix-length=4 --lines="$CHUNK_SIZE" "$DAT_FILE" "$DAT_SPLIT_PREFIX"
done
sendStatusEmailDisable "Split data into chunks..."

# run PostgreSQL schemas to create tables in validation schema
# shellcheck disable=SC2086
jq -r ".tables[].name" "$CONFIG_FILE" | while read -r table; do
  PG_SQL_FILE="$DIR_PG/$table.sql"
  env $(xargs < "$HOME/cot-env.config") psql -f "$PG_SQL_FILE"
  if env $(xargs < "$HOME/cot-env.config") psql -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = '$TARGET_VALIDATION_SCHEMA' AND table_name = '$table')" | grep f; then
    exitError "Failed to create table $TARGET_VALIDATION_SCHEMA.$table in remote PostgreSQL!"
  fi
  if env $(xargs < "$HOME/cot-env.config") psql -tAc "SELECT EXISTS (SELECT 1 FROM pg_matviews WHERE schemaname = '$TARGET_SCHEMA' AND matviewname = '$table')" | grep f; then
    exitError "Failed to create materialized view $TARGET_SCHEMA.$table in remote PostgreSQL!"
  fi
done
sendStatusEmailDisable "Created remote PostgreSQL validation tables and live materialized views..."

# truncate validation schema tables
# shellcheck disable=SC2086
jq -r ".tables[].name" "$CONFIG_FILE" | while read -r table; do
  env $(xargs < "$HOME/cot-env.config") psql -c "TRUNCATE TABLE \"$TARGET_VALIDATION_SCHEMA\".\"$table\" RESTART IDENTITY"
  if env $(xargs < "$HOME/cot-env.config") psql -tAc "SELECT EXISTS (SELECT * FROM \"$TARGET_VALIDATION_SCHEMA\".\"$table\")" | grep t; then
    exitError "Failed to truncate $TARGET_VALIDATION_SCHEMA.$table in remote PostgreSQL!"
  fi
done
sendStatusEmailDisable "Truncated remote PostgreSQL validation tables..."

# copy data from local text files to tables in validation schema
# shellcheck disable=SC2086
jq -r ".tables[].name" "$CONFIG_FILE" | while read -r table; do
  # copy chunks
  DAT_SPLIT_PREFIX="$DIR_DAT_SPLIT/$table.dat."
  # shellcheck disable=SC2012
  ls ${DAT_SPLIT_PREFIX}* | while read -r dat_split_file; do
    env $(xargs < "$HOME/cot-env.config") psql -c "\COPY \"$TARGET_VALIDATION_SCHEMA\".\"$table\" FROM STDIN (FORMAT text, ENCODING 'UTF8')" < "$dat_split_file"
    sendStatusEmailDisable "Copied $dat_split_file..."
  done
  sendStatusEmailDisable "Copied all splits for $TARGET_VALIDATION_SCHEMA.$table..."

  # ensure that statistics exist using ANALYZE
  env $(xargs < "$HOME/cot-env.config") psql -c "ANALYZE \"$TARGET_VALIDATION_SCHEMA\".\"$table\""

  # check that row counts match within tolerance
  PG_COUNT=$(env $(xargs < "$HOME/cot-env.config") psql -tAc "SELECT reltuples::BIGINT FROM pg_class JOIN pg_catalog.pg_namespace n ON n.oid = pg_class.relnamespace WHERE nspname = '$TARGET_VALIDATION_SCHEMA' AND relname = '$table'")
  ORA_COUNT=$(cat "$DIR_ORA_CNT/$table.cnt")
  BC_EXPR="($PG_COUNT - $ORA_COUNT) / $ORA_COUNT"
  BC_EXPR="(-$ROW_COUNT_TOLERANCE < ($BC_EXPR)) && (($BC_EXPR) < $ROW_COUNT_TOLERANCE)"
  ROW_COUNT_VALID=$(echo "$BC_EXPR" | bc)
  if [ "$ROW_COUNT_VALID" = "0" ]; then
    exitError "Row count mismatch on $TARGET_VALIDATION_SCHEMA.$table: Oracle ($ORA_COUNT rows) -> PostgreSQL ($PG_COUNT rows)!"
  fi
  sendStatusEmailDisable "Validated $TARGET_VALIDATION_SCHEMA.$table..."
done
sendStatusEmailDisable "Copied data into remote PostgreSQL validation schema..."

# refresh materialized views in target schema
# shellcheck disable=SC2086
jq -r ".tables[].name" "$CONFIG_FILE" | while read -r table; do
  env $(xargs < "$HOME/cot-env.config") psql -c "REFRESH MATERIALIZED VIEW CONCURRENTLY \"$TARGET_SCHEMA\".\"$table\""
done
sendStatusEmailDisable "Refreshed materialized views in remote PostgreSQL target schema..."
exitSuccess "Finished remote PostgreSQL data transfer."
