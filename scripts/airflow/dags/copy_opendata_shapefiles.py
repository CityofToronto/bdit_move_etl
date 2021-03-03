"""
copy_opendata_shapefiles

Copy important datasets in SHP format over to the RDS.
"""
# pylint: disable=pointless-statement
from datetime import datetime

from airflow.operators.bash_operator import BashOperator

from airflow_utils import create_bash_task_nested, create_dag

START_DATE = datetime(2020, 2, 27)
SCHEDULE_INTERVAL = '30 4 * * 6'
DAG = create_dag(__file__, __doc__, START_DATE, SCHEDULE_INTERVAL)

# The Open Data Portal (i.e. CKAN) stores resources at URLs of format
# `${BASE_URL}/dataset/${DATASET_ID}/resource/${RESOURCE_ID}/download/${FILENAME}`.
#
# To find these resource URLs:
#
# - find the dataset in the Open Data Portal (for instance, the Toronto Centreline
#   is at https://open.toronto.ca/dataset/toronto-centreline-tcl/);
# - open the "For Developers" tab in the carousel;
# - find the dataset ID listed in `params`;
# - use this to request `${BASE_URL}/action/package_show?id=${DATASET_ID}`;
# - in there, look for the URL under `result.resources[].url`.
#
TASKS = {
  'centreline': 'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/1d079757-377b-4564-82df-eb5638583bfb/resource/cf55ca33-d5ff-427b-9d7a-615db0cebdaa/download/centreline_wgs84_v2.zip',
  'centreline_intersection': 'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/2c83f641-7808-49ba-b80f-7011851d4e27/resource/1d84f2f9-f551-477e-a7fa-f92caf2ae28d/download/intersection-file-wgs84.zip'
}

INDEX_OPENDATA = create_bash_task_nested(DAG, 'index_opendata')

for task_id, resource_url in TASKS.items():
  task_id_extract = '{0}_extract'.format(task_id)
  EXTRACT_OPENDATA_SHAPEFILE = BashOperator(
    task_id=task_id_extract,
    bash_command='/copy_opendata_shapefiles/extract_opendata_shapefile.sh',
    params={
      'resource_url': resource_url,
      'name': task_id
    },
    dag=DAG
  )

  task_id_load = '{0}_load'.format(task_id)
  LOAD_SHAPEFILE = BashOperator(
    task_id=task_id_load,
    bash_command='/copy_opendata_shapefiles/load_shapefile.sh',
    params={
      'name': task_id
    },
    dag=DAG
  )

  EXTRACT_OPENDATA_SHAPEFILE >> LOAD_SHAPEFILE
  LOAD_SHAPEFILE >> INDEX_OPENDATA
