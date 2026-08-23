from datetime import datetime
from airflow.sdk import dag, task
from airflow.providers.common.ai.operators.llm import LLMOperator

@dag(dag_id="18_llm_data_classification", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def classification():
    @task
    def get_feedback():
        return [
            "The checkout was very fast.",
            "Payment failed twice.",
            "Delivery was late.",
        ]

    @task
    def classify_with_llm(text):
        # Educational pattern: each mapped task can invoke an LLM.
        return text

    classify_with_llm.expand(text=get_feedback())

classification()
