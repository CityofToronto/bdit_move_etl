"""
arteries_geocoding

Use arterycode matching information and processes as built by Aakash (Big Data) and others
to link counts with the Toronto centreline.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow_utils import create_dag, create_bash_task_nested

START_DATE = datetime(2021, 1, 11)
SCHEDULE_INTERVAL = '0 7 * * 6'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

A1_ARTERIES_MANUAL_CORR = create_bash_task_nested(DAG, 'A1_arteries_manual_corr')
A1_NODES_CORRECTED = create_bash_task_nested(DAG, 'A1_nodes_corrected')
A2_NODES_CENTRELINE = create_bash_task_nested(DAG, 'A2_nodes_centreline')
B1_ARTERIES_PX_CENTRELINE = create_bash_task_nested(DAG, 'B1_arteries_px_centreline')
B2_ARTERIES_MANUAL_CORR_NORMALIZED = create_bash_task_nested(DAG, 'B2_arteries_manual_corr_normalized')
C1_ARTERIES_LINKS = create_bash_task_nested(DAG, 'C1_arteries_links')
C2_ARTERIES_DOUBLE_NODE_INTERSECTIONS = create_bash_task_nested(DAG, 'C2_arteries_double_node_intersections')
C2_ARTERIES_SINGLE_NODE = create_bash_task_nested(DAG, 'C2_arteries_single_node')
C3_ARTERIES_DOUBLE_NODE_MIDBLOCKS = create_bash_task_nested(DAG, 'C3_arteries_double_node_midblocks')
C4_ARTERIES_DOUBLE_NODE_MIDBLOCKS_MULTI_BEST = create_bash_task_nested(DAG, 'C4_arteries_double_node_midblocks_multi_best')
D1_ARTERIES_CENTRELINE_TABLE = create_bash_task_nested(DAG, 'D1_arteries_centreline_table')
D2_ARTERY_GEOCODING = create_bash_task_nested(DAG, 'D2_artery_geocoding')
D3_ARTERIES_CENTRELINE_VIEW = create_bash_task_nested(DAG, 'D3_arteries_centreline_view')

A1_NODES_CORRECTED >> A2_NODES_CENTRELINE
A1_ARTERIES_MANUAL_CORR >> B2_ARTERIES_MANUAL_CORR_NORMALIZED
A2_NODES_CENTRELINE >> C2_ARTERIES_DOUBLE_NODE_INTERSECTIONS
C1_ARTERIES_LINKS >> C2_ARTERIES_DOUBLE_NODE_INTERSECTIONS
A2_NODES_CENTRELINE >> C2_ARTERIES_SINGLE_NODE
C1_ARTERIES_LINKS >> C2_ARTERIES_SINGLE_NODE
C2_ARTERIES_DOUBLE_NODE_INTERSECTIONS >> C3_ARTERIES_DOUBLE_NODE_MIDBLOCKS
C3_ARTERIES_DOUBLE_NODE_MIDBLOCKS >> C4_ARTERIES_DOUBLE_NODE_MIDBLOCKS_MULTI_BEST
A2_NODES_CENTRELINE >> D1_ARTERIES_CENTRELINE_TABLE
B1_ARTERIES_PX_CENTRELINE >> D1_ARTERIES_CENTRELINE_TABLE
B2_ARTERIES_MANUAL_CORR_NORMALIZED >> D1_ARTERIES_CENTRELINE_TABLE
C1_ARTERIES_LINKS >> D1_ARTERIES_CENTRELINE_TABLE
C2_ARTERIES_SINGLE_NODE >> D1_ARTERIES_CENTRELINE_TABLE
C2_ARTERIES_DOUBLE_NODE_INTERSECTIONS >> D1_ARTERIES_CENTRELINE_TABLE
C3_ARTERIES_DOUBLE_NODE_MIDBLOCKS >> D1_ARTERIES_CENTRELINE_TABLE
C4_ARTERIES_DOUBLE_NODE_MIDBLOCKS_MULTI_BEST >> D1_ARTERIES_CENTRELINE_TABLE
D1_ARTERIES_CENTRELINE_TABLE >> D2_ARTERY_GEOCODING
D2_ARTERY_GEOCODING >> D3_ARTERIES_CENTRELINE_VIEW
