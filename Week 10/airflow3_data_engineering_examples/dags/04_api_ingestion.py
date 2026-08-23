from datetime import datetime
from airflow.sdk import dag
from airflow.providers.http.operators.http import HttpOperator

@dag(dag_id="04_api_ingestion", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def api_ingestion():
    get_data = HttpOperator(
        task_id="get_api_data",
        http_conn_id="external_api",
        endpoint="/transactions",
        method="GET",
    )
    get_data

api_ingestion()
