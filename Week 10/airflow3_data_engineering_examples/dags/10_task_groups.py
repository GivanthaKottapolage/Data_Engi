from datetime import datetime
from airflow.sdk import dag, task_group
from airflow.providers.standard.operators.bash import BashOperator

@dag(dag_id="10_task_groups", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def task_groups():
    @task_group
    def ingestion():
        extract = BashOperator(task_id="extract", bash_command="echo extract")
        validate = BashOperator(task_id="validate", bash_command="echo validate")
        extract >> validate

    @task_group
    def transformation():
        clean = BashOperator(task_id="clean", bash_command="echo clean")
        aggregate = BashOperator(task_id="aggregate", bash_command="echo aggregate")
        clean >> aggregate

    ingestion() >> transformation()

task_groups()
