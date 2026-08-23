from datetime import datetime
from airflow.sdk import dag
from airflow.providers.standard.operators.trigger_dagrun import TriggerDagRunOperator

@dag(dag_id="13_trigger_pipeline", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def trigger_pipeline():
    TriggerDagRunOperator(
        task_id="trigger_downstream",
        trigger_dag_id="downstream_pipeline",
        wait_for_completion=True,
    )

trigger_pipeline()
