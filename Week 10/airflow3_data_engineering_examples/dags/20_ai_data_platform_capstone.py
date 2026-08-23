from datetime import datetime
from airflow.sdk import dag, task, Asset
from airflow.providers.common.ai.operators.llm import LLMOperator

raw_asset = Asset("s3://data-lake/raw/customer_feedback")

@dag(dag_id="20_ai_data_platform_capstone", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def ai_data_platform():
    @task(outlets=[raw_asset])
    def ingest():
        return [
            "Payment failed twice.",
            "Checkout was excellent.",
            "Delivery was delayed.",
        ]

    @task
    def prepare(text):
        return text

    @task
    def store(result):
        print("Store AI-enriched result:", result)

    feedback = prepare(ingest())

    # In a production version, use LLMOperator with dynamic mapping or
    # @task.llm according to the installed common-ai provider version.
    store.expand(result=feedback)

ai_data_platform()
