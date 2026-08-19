from datetime import datetime
from pathlib import Path
import sys

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

from airflow import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.standard.sensors.external_task import ExternalTaskSensor
from airflow.providers.postgres.hooks.postgres import PostgresHook

from utils.file import read_sql


DB_CONN_ID = "postgres_dw"

SQL_DIR = BASE_DIR / "sql" / "gold" / "facts"

SILVER_DAG_ID = "02_load_silver_layer"
GOLD_DIMENSION_DAG_ID = "04_load_gold_dimensions"


def load_gold_fact(sql_file: str):

    sql = read_sql(SQL_DIR / sql_file)

    hook = PostgresHook(
        postgres_conn_id=DB_CONN_ID
    )

    conn = hook.get_conn()

    try:

        with conn.cursor() as cursor:
            cursor.execute(sql)

        conn.commit()

        print(
            f"Successfully loaded fact: {sql_file}"
        )

    except Exception:

        conn.rollback()

        raise

    finally:

        conn.close()


default_args = {
    "owner": "freshbank",
    "retries": 1,
}


with DAG(
    dag_id="05_load_gold_facts",

    description="Load Gold Fact Tables",

    start_date=datetime(2026, 1, 1),

    schedule='@daily',

    catchup=False,

    default_args=default_args,

    max_active_runs=1,

    tags=[
        "gold",
        "facts",
        "training",
    ],
) as dag:

    start = EmptyOperator(
        task_id="start"
    )

    # ================================================================
    # WAIT FOR SILVER TRANSACTION
    # ================================================================

    wait_transaction = ExternalTaskSensor(
        task_id="wait_for_silver_transaction",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_transaction",

        allowed_states=["success"],

        failed_states=[
            "failed",
            "skipped",
        ],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    # ================================================================
    # WAIT FOR GOLD DIMENSIONS
    # ================================================================

    wait_dimensions = ExternalTaskSensor(
        task_id="wait_for_gold_dimensions",

        external_dag_id=GOLD_DIMENSION_DAG_ID,

        external_task_id="load_dim_customer",

        allowed_states=["success"],

        failed_states=[
            "failed",
            "skipped",
        ],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    # ================================================================
    # TRANSACTION FACT
    # ================================================================

    load_transaction_fact = PythonOperator(
        task_id="load_fact_transaction",

        python_callable=load_gold_fact,

        op_kwargs={
            "sql_file": "fact_transaction.sql"
        },
    )

    # ================================================================
    # LOAN REPAYMENT
    # ================================================================

    wait_loan_repayment = ExternalTaskSensor(
        task_id="wait_for_silver_loan_repayment",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_loan_repayment",

        allowed_states=["success"],

        failed_states=[
            "failed",
            "skipped",
        ],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_loan_repayment = PythonOperator(
        task_id="load_fact_loan_repayment",

        python_callable=load_gold_fact,

        op_kwargs={
            "sql_file": "fact_loan_repayment.sql"
        },
    )

    # ================================================================
    # ACCOUNT SNAPSHOT
    # ================================================================

    wait_account = ExternalTaskSensor(
        task_id="wait_for_silver_account",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_account",

        allowed_states=["success"],

        failed_states=[
            "failed",
            "skipped",
        ],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_account_snapshot = PythonOperator(
        task_id="load_fact_account_daily_snapshot",

        python_callable=load_gold_fact,

        op_kwargs={
            "sql_file": "fact_account_daily_snapshot.sql"
        },
    )

    # ================================================================
    # DEPENDENCIES
    # ================================================================

    start >> [
        wait_transaction,
        wait_loan_repayment,
        wait_account,
    ]

    wait_transaction >> wait_dimensions

    wait_dimensions >> load_transaction_fact

    wait_loan_repayment >> load_loan_repayment

    wait_account >> load_account_snapshot