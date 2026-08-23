from datetime import datetime
from airflow.sdk import dag
from airflow.providers.standard.operators.bash import BashOperator

@dag(dag_id="01_basic_etl", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def basic_etl():
    extract = BashOperator(task_id="extract", bash_command="echo 'Extracting data'")
    transform = BashOperator(task_id="transform", bash_command="echo 'Transforming data'")
    load = BashOperator(task_id="load", bash_command="echo 'Loading data'")
    extract >> transform >> load

basic_etl()
