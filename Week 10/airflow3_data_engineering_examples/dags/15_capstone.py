from datetime import datetime
from airflow.sdk import dag, task, Asset

raw_transactions = Asset("s3://data-lake/raw/transactions")

@dag(dag_id="15_modern_data_platform", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def modern_data_platform():
    @task(outlets=[raw_transactions])
    def ingest_api():
        print("Ingest API data and publish/update raw asset")
        return ["customers", "orders", "transactions"]

    @task
    def validate(data):
        print(f"Validate datasets: {data}")
        return data

    @task
    def process(dataset):
        print(f"Process {dataset}")

    datasets = validate(ingest_api())
    process.expand(dataset=datasets)

modern_data_platform()
