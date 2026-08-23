from datetime import datetime
from pydantic import BaseModel
from airflow.sdk import dag
from airflow.providers.common.ai.operators.llm import LLMOperator

class Incident(BaseModel):
    severity: str
    category: str
    summary: str
    recommended_action: str

@dag(dag_id="17_llm_structured_extraction", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def structured_extraction():
    LLMOperator(
        task_id="extract_incident",
        prompt="Extract a structured incident from this text: 'The payments pipeline failed after the source API returned 503 for 20 minutes.'",
        llm_conn_id="pydanticai_default",
        model_id="openai:gpt-5",
        output_type=Incident,
    )

structured_extraction()
