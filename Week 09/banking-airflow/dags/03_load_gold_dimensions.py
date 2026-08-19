from datetime import datetime
from pathlib import Path
import sys

# --------------------------------------------------------------------
# Path configuration
# --------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

from airflow import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.standard.sensors.external_task import ExternalTaskSensor
from airflow.providers.postgres.hooks.postgres import PostgresHook

from utils.file import read_sql


# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------

DB_CONN_ID = "postgres_dw"

SQL_DIR = BASE_DIR / "sql" / "gold" / "dimensions"

SILVER_DAG_ID = "02_load_silver_layer"


# --------------------------------------------------------------------
# Generic Gold Dimension Loader
# --------------------------------------------------------------------

def load_gold_dimension(sql_file: str):

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
            f"Successfully processed Gold dimension: {sql_file}"
        )

    except Exception:
        conn.rollback()
        raise

    finally:
        conn.close()


# --------------------------------------------------------------------
# DAG
# --------------------------------------------------------------------

default_args = {
    "owner": "freshbank",
    "retries": 1,
}


with DAG(
    dag_id="04_load_gold_dimensions",
    description="Load Gold Dimension Tables",
    start_date=datetime(2026, 1, 1),
    schedule='@daily',
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    tags=["gold", "dimensions", "scd", "training"],
) as dag:

    start = EmptyOperator(
        task_id="start"
    )

    # ================================================================
    # CUSTOMER
    # ================================================================

    wait_customer_profile = ExternalTaskSensor(
        task_id="wait_for_silver_customer_profile",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_customer_profile",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_customer = PythonOperator(
        task_id="load_dim_customer",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_customer.sql"
        },
    )

    # ================================================================
    # BRANCH
    # ================================================================

    wait_branch = ExternalTaskSensor(
        task_id="wait_for_silver_branch",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_branch",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_branch = PythonOperator(
        task_id="load_dim_branch",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_branch.sql"
        },
    )

    # ================================================================
    # EMPLOYEE
    # ================================================================

    wait_employee = ExternalTaskSensor(
        task_id="wait_for_silver_employee",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_employee",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_employee = PythonOperator(
        task_id="load_dim_employee",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_employee.sql"
        },
    )

    # ================================================================
    # ACCOUNT
    # ================================================================

    wait_account = ExternalTaskSensor(
        task_id="wait_for_silver_account",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_account",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_account = PythonOperator(
        task_id="load_dim_account",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_account.sql"
        },
    )

    # ================================================================
    # LOAN
    # ================================================================

    wait_loan = ExternalTaskSensor(
        task_id="wait_for_silver_loan",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_loan",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_loan = PythonOperator(
        task_id="load_dim_loan",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_loan.sql"
        },
    )

    # ================================================================
    # CARD
    # ================================================================

    wait_card = ExternalTaskSensor(
        task_id="wait_for_silver_card",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_card",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_card = PythonOperator(
        task_id="load_dim_card",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_card.sql"
        },
    )

    # ================================================================
    # ATM
    # ================================================================

    wait_atm = ExternalTaskSensor(
        task_id="wait_for_silver_atm",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_atm",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_atm = PythonOperator(
        task_id="load_dim_atm",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_atm.sql"
        },
    )

    # ================================================================
    # MERCHANT
    # ================================================================

    wait_merchant = ExternalTaskSensor(
        task_id="wait_for_silver_merchant",

        external_dag_id=SILVER_DAG_ID,

        external_task_id="load_silver_merchant",

        allowed_states=["success"],

        failed_states=["failed", "skipped"],

        mode="reschedule",

        poke_interval=30,

        timeout=60 * 60,
    )

    load_merchant = PythonOperator(
        task_id="load_dim_merchant",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_merchant.sql"
        },
    )

    # ================================================================
    # DATE
    # ================================================================

    load_date = PythonOperator(
        task_id="load_dim_date",

        python_callable=load_gold_dimension,

        op_kwargs={
            "sql_file": "dim_date.sql"
        },
    )

    # ================================================================
    # DEPENDENCIES
    # ================================================================

    start >> [
        wait_customer_profile,
        wait_branch,
        wait_employee,
        wait_account,
        wait_loan,
        wait_card,
        wait_atm,
        wait_merchant,
        load_date,
    ]

    wait_customer_profile >> load_customer
    wait_branch >> load_branch
    wait_employee >> load_employee
    wait_account >> load_account
    wait_loan >> load_loan
    wait_card >> load_card
    wait_atm >> load_atm
    wait_merchant >> load_merchant