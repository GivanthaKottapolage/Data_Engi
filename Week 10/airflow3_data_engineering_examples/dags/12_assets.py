from datetime import datetime
from airflow.sdk import dag, Asset
from airflow.providers.standard.operators.bash import BashOperator

transactions = Asset("s3://data-lake/transactions.parquet")

@dag(dag_id="12_asset_producer", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def producer():
    BashOperator(
        task_id="produce",
        bash_command="echo 'Creating transactions dataset'",
        outlets=[transactions],
    )

@dag(dag_id="12_asset_consumer", schedule=[transactions], catchup=False)
def consumer():
    BashOperator(
        task_id="process",
        bash_command="echo 'Processing transactions asset'",
    )

producer()
consumer()
