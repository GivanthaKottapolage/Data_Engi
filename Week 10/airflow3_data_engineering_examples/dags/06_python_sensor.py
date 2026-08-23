from datetime import datetime
from airflow.sdk import dag
from airflow.providers.standard.sensors.python import PythonSensor
from airflow.providers.standard.operators.bash import BashOperator

def check_source_ready():
    # Replace with an API/database/business-rule check.
    return True

@dag(dag_id="06_python_sensor", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def source_ready_pipeline():
    wait_for_source = PythonSensor(
        task_id="wait_for_source",
        python_callable=check_source_ready,
        poke_interval=60, timeout=3600, mode="reschedule",
    )
    process = BashOperator(task_id="process", bash_command="echo 'Source is ready'")
    wait_for_source >> process

source_ready_pipeline()
