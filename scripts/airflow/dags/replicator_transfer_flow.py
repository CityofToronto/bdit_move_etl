"""
replicator_transfer_flow

Complete replication of FLOW data by loading it from `/data/replicator/flashcrow-FLOW`
into the database.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow.operators.bash_operator import BashOperator

from airflow_utils import create_bash_task_nested, create_dag

START_DATE = datetime(2020, 10, 15)
SCHEDULE_INTERVAL = '30 3 * * 6'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

REPLICATOR_TRANSFER_FLOW = BashOperator(
  task_id='replicator_transfer_flow',
  bash_command='/replicator_transfer/replicator-transfer-FLOW.sh',
  dag=DAG
)
