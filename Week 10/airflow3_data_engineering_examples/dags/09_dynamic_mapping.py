from datetime import datetime
from airflow.sdk import dag, task

@dag(dag_id="09_dynamic_mapping", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def dynamic_mapping():
    @task
    def get_files():
        return ["customers.csv", "orders.csv", "transactions.csv", "payments.csv"]

    @task
    def process_file(filename):
        print(f"Processing {filename}")

    process_file.expand(filename=get_files())

dynamic_mapping()
