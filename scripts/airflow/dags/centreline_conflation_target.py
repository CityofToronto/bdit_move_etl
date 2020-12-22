"""
centreline_conflation_target

Normalize the Toronto Centreline into common "conflation target" and "routing target"
views, for use by other pipelines.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow_utils import create_dag, create_bash_task_nested

START_DATE = datetime(2020, 12, 21)
SCHEDULE_INTERVAL = '30 5 * * 6'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

A1_INTERSECTION_IDS = create_bash_task_nested(DAG, 'A1_intersection_ids')
A2_INTERSECTIONS = create_bash_task_nested(DAG, 'A2_intersections')
A2_ROUTING_VERTICES = create_bash_task_nested(DAG, 'A2_routing_vertices')
A3_MIDBLOCK_NAMES = create_bash_task_nested(DAG, 'A3_midblock_names')
A4_MIDBLOCKS = create_bash_task_nested(DAG, 'A4_midblocks')
A5_ROUTING_EDGES = create_bash_task_nested(DAG, 'A5_routing_edges')

A1_INTERSECTION_IDS >> A2_INTERSECTIONS
A1_INTERSECTION_IDS >> A2_ROUTING_VERTICES
A2_INTERSECTIONS >> A3_MIDBLOCK_NAMES
A3_MIDBLOCK_NAMES >> A4_MIDBLOCKS
A2_ROUTING_VERTICES >> A5_ROUTING_EDGES
A4_MIDBLOCKS >> A5_ROUTING_EDGES
