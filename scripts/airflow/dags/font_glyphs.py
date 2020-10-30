"""
font_glyphs

Generate signed-distance field font glyphs using the `openmaptiles/fonts` repo on GitHub.
This allows us to serve our own fonts for use with Mapbox GL.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow_utils import create_dag, create_bash_task_nested

START_DATE = datetime(2020, 10, 29)
SCHEDULE_INTERVAL = '0 0 1 * *'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

FONT_GLYPHS = create_bash_task_nested(DAG, 'font_glyphs')
