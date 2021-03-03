"""
open_data_tmcs

Build open dataset for Turning Movement Counts.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow_utils import create_dag, create_bash_task_nested

START_DATE = datetime(2021, 3, 2)
SCHEDULE_INTERVAL = '15 7 * * 6'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

A1_TMCS_COUNT_DATA = create_bash_task_nested(DAG, 'A1_tmcs_count_data')
A1_TMCS_COUNT_METADATA = create_bash_task_nested(DAG, 'A1_tmcs_count_metadata')
A2_TMCS_LOCATIONS = create_bash_task_nested(DAG, 'A2_tmcs_locations')
A3_TMCS_JOINED = create_bash_task_nested(DAG, 'A3_tmcs_joined')
A4_TMCS_DECADES = create_bash_task_nested(DAG, 'A4_tmcs_decades')
A4_TMCS_PREVIEW = create_bash_task_nested(DAG, 'A4_tmcs_preview')

A1_TMCS_COUNT_DATA >> A2_TMCS_LOCATIONS
A1_TMCS_COUNT_METADATA >> A2_TMCS_LOCATIONS
A2_TMCS_LOCATIONS >> A3_TMCS_JOINED
A3_TMCS_JOINED >> A4_TMCS_DECADES
A3_TMCS_JOINED >> A4_TMCS_PREVIEW
