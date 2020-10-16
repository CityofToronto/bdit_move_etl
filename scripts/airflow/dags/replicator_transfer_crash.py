"""
replicator_transfer_crash

Complete replication of CRASH data by loading it from `/data/replicator/flashcrow-CRASH`
into the database.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow.operators.bash_operator import BashOperator

from airflow_utils import create_dag

START_DATE = datetime(2020, 10, 15)
SCHEDULE_INTERVAL = '10 19 * * 1-5'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

REPLICATOR_TRANSFER_CRASH = BashOperator(
  task_id='replicator_transfer_crash',
  bash_command='/replicator_transfer/replicator-transfer-CRASH.sh',
  dag=DAG
)
