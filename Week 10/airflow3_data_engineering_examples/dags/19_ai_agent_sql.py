from datetime import datetime
from airflow.sdk import dag
from airflow.providers.common.ai.operators.agent import AgentOperator

@dag(dag_id="19_ai_agent_sql", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def ai_agent_sql():
    AgentOperator(
        task_id="analyst",
        prompt="Analyze the warehouse and identify the top 5 customers by transaction count. Explain the SQL-based result.",
        llm_conn_id="pydanticai_default",
        # Configure the appropriate SQL/toolset for your Airflow environment.
    )

ai_agent_sql()
