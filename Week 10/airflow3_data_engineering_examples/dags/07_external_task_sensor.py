from datetime import datetime
from airflow.sdk import dag
from airflow.providers.standard.sensors.external_task import ExternalTaskSensor
from airflow.providers.standard.operators.bash import BashOperator

@dag(dag_id="07_external_dependency", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def transaction_pipeline():
    wait_for_customer = ExternalTaskSensor(
        task_id="wait_for_customer",
        external_dag_id="customer_pipeline",
        external_task_id="load_customer",
        mode="reschedule",
    )
    process = BashOperator(task_id="process_transaction", bash_command="echo 'Processing transactions'")
    wait_for_customer >> process

transaction_pipeline()
