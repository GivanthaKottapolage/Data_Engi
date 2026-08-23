from datetime import datetime
from airflow.sdk import dag
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator

@dag(dag_id="11_kubernetes_processing", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def kubernetes_processing():
    KubernetesPodOperator(
        task_id="run_processing",
        name="data-processing",
        namespace="data",
        image="mycompany/data-processing:latest",
        cmds=["python"],
        arguments=["/app/process.py"],
        get_logs=True,
    )

kubernetes_processing()
