from datetime import datetime
from airflow.sdk import dag, task

@dag(dag_id="02_python_taskflow", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def python_taskflow():
    @task
    def extract():
        return [10, 20, 30, 40]

    @task
    def transform(data):
        return [x * 2 for x in data]

    @task
    def load(data):
        print(f"Loading: {data}")

    load(transform(extract()))

python_taskflow()
