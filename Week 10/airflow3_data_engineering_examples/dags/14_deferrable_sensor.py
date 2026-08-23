from datetime import datetime, timedelta
from airflow.sdk import dag
from airflow.providers.standard.sensors.time_delta import TimeDeltaSensor

@dag(dag_id="14_deferrable_sensor", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def deferrable_example():
    TimeDeltaSensor(
        task_id="wait",
        delta=timedelta(minutes=10),
        deferrable=True,
    )

deferrable_example()
