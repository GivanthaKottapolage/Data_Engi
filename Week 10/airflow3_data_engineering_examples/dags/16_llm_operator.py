from datetime import datetime
from airflow.sdk import dag
from airflow.providers.common.ai.operators.llm import LLMOperator

@dag(dag_id="16_llm_operator", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def llm_operator():
    LLMOperator(
        task_id="summarize",
        prompt="Summarize the following data engineering incident in three bullet points: {{ dag_run.conf.get('incident', 'Example pipeline failed because source data was late.') }}",
        llm_conn_id="pydanticai_default",
        model_id="openai:gpt-5",
        system_prompt="You are a concise data engineering assistant.",
    )

llm_operator()
