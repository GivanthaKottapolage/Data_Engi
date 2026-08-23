from datetime import datetime
from airflow.sdk import dag, task
from airflow.providers.standard.operators.bash import BashOperator

@dag(dag_id="08_branching", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def branching():
    @task.branch
    def validate():
        data_valid = True
        return "success" if data_valid else "reject"

    success = BashOperator(task_id="success", bash_command="echo 'Data accepted'")
    reject = BashOperator(task_id="reject", bash_command="echo 'Data rejected'")
    validate() >> [success, reject]

branching()
