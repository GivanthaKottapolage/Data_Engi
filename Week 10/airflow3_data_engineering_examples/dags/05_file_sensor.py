from datetime import datetime
from airflow.sdk import dag
from airflow.providers.standard.sensors.filesystem import FileSensor
from airflow.providers.standard.operators.bash import BashOperator

@dag(dag_id="05_file_sensor", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def file_pipeline():
    wait_for_file = FileSensor(
        task_id="wait_for_file",
        filepath="/data/incoming/customers.csv",
        poke_interval=60, timeout=3600, mode="reschedule",
    )
    process = BashOperator(task_id="process_file", bash_command="python /scripts/process_customers.py")
    wait_for_file >> process

file_pipeline()
