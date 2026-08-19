from datetime import datetime
from pathlib import Path
import sys

# --------------------------------------------------------------------
# Make sure the dags folder is on the path
# BEFORE importing anything from utils
# --------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))


from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor

from utils.database import extract_data, truncate_table, load_data
from utils.file import read_sql


# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------

SOURCE_CONN = "postgres_dw"
TARGET_CONN = "postgres_dw"

SQL_DIR = BASE_DIR / "sql"

BRONZE_DAG_ID = "02_incremental_load_bronze"


# --------------------------------------------------------------------
# Generic Silver Loader
# --------------------------------------------------------------------

def load_silver_table(sql_file: str, target_table: str):

    sql = read_sql(SQL_DIR / sql_file)

    columns, rows = extract_data(
        conn_id=SOURCE_CONN,
        sql=sql,
    )

    truncate_table(
        conn_id=TARGET_CONN,
        table_name=target_table,
    )

    if rows:
        load_data(
            conn_id=TARGET_CONN,
            table_name=target_table,
            columns=columns,
            rows=rows,
        )

    print(
        f"Loaded {len(rows)} rows into {target_table}"
    )


# --------------------------------------------------------------------
# External Bronze Sensor
# --------------------------------------------------------------------

def bronze_sensor(task_id: str, sensor_task_id: str):

    return ExternalTaskSensor(
        task_id=task_id,
        external_dag_id=BRONZE_DAG_ID,
        external_task_id=sensor_task_id,
        allowed_states=["success"],
        failed_states=["failed", "skipped"],
        mode="reschedule",
        poke_interval=30,
        timeout=60 * 60,
    )


# --------------------------------------------------------------------
# DAG configuration
# --------------------------------------------------------------------

default_args = {
    "owner": "freshbank",
    "retries": 1,
}


# --------------------------------------------------------------------
# DAG
# --------------------------------------------------------------------

with DAG(
    dag_id="02_load_silver_layer",
    description="Build Silver layer from completed Bronze tables",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    schedule="@daily",
    tags=["silver", "training", "medallion"],
) as dag:

    start = EmptyOperator(
        task_id="start"
    )

    # ================================================================
    # CUSTOMER
    # ================================================================

    wait_for_bronze_customer = bronze_sensor(
        "wait_for_bronze_customer",
        "load_bronze_customer",
    )

    load_customer = PythonOperator(
        task_id="load_silver_customer",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/customer.sql",
            "target_table": "silver.customer",
        },
    )

    wait_for_bronze_customer >> load_customer


    # ================================================================
    # CUSTOMER ADDRESS
    # ================================================================

    wait_for_bronze_customer_address = bronze_sensor(
        "wait_for_bronze_customer_address",
        "load_bronze_customer_address",
    )

    load_customer_address = PythonOperator(
        task_id="load_silver_customer_address",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/customer_address.sql",
            "target_table": "silver.customer_address",
        },
    )

    wait_for_bronze_customer_address >> load_customer_address


    # ================================================================
    # CUSTOMER PHONE
    # ================================================================

    wait_for_bronze_customer_phone = bronze_sensor(
        "wait_for_bronze_customer_phone",
        "load_bronze_customer_phone",
    )

    load_customer_phone = PythonOperator(
        task_id="load_silver_customer_phone",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/customer_phone.sql",
            "target_table": "silver.customer_phone",
        },
    )

    wait_for_bronze_customer_phone >> load_customer_phone


    # ================================================================
    # CUSTOMER PROFILE
    #
    # Depends on all three cleaned customer entities.
    #
    # customer
    # customer_address
    # customer_phone
    #       ↓
    # customer_profile
    # ================================================================

    load_customer_profile = PythonOperator(
        task_id="load_silver_customer_profile",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/customer_profile.sql",
            "target_table": "silver.customer_profile",
        },
    )

    [
        load_customer,
        load_customer_address,
        load_customer_phone,
    ] >> load_customer_profile


    # ================================================================
    # BRANCH
    # ================================================================

    wait_for_bronze_branch = bronze_sensor(
        "wait_for_bronze_branch",
        "load_bronze_branch",
    )

    load_branch = PythonOperator(
        task_id="load_silver_branch",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/branch.sql",
            "target_table": "silver.branch",
        },
    )

    wait_for_bronze_branch >> load_branch


    # ================================================================
    # EMPLOYEE
    # ================================================================

    wait_for_bronze_employee = bronze_sensor(
        "wait_for_bronze_employee",
        "load_bronze_employee",
    )

    load_employee = PythonOperator(
        task_id="load_silver_employee",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/employee.sql",
            "target_table": "silver.employee",
        },
    )

    wait_for_bronze_employee >> load_employee


    # ================================================================
    # ACCOUNT
    # ================================================================

    wait_for_bronze_account = bronze_sensor(
        "wait_for_bronze_account",
        "load_bronze_account",
    )

    load_account = PythonOperator(
        task_id="load_silver_account",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/account.sql",
            "target_table": "silver.account",
        },
    )

    wait_for_bronze_account >> load_account


    # ================================================================
    # ACCOUNT OWNERSHIP
    # ================================================================

    wait_for_bronze_account_ownership = bronze_sensor(
        "wait_for_bronze_account_ownership",
        "load_bronze_account_ownership",
    )

    load_account_ownership = PythonOperator(
        task_id="load_silver_account_ownership",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/account_ownership.sql",
            "target_table": "silver.account_ownership",
        },
    )

    wait_for_bronze_account_ownership >> load_account_ownership


    # ================================================================
    # LOAN
    # ================================================================

    wait_for_bronze_loan = bronze_sensor(
        "wait_for_bronze_loan",
        "load_bronze_loan",
    )

    load_loan = PythonOperator(
        task_id="load_silver_loan",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/loan.sql",
            "target_table": "silver.loan",
        },
    )

    wait_for_bronze_loan >> load_loan


    # ================================================================
    # LOAN REPAYMENT
    # ================================================================

    wait_for_bronze_loan_repayment = bronze_sensor(
        "wait_for_bronze_loan_repayment",
        "load_bronze_loan_repayment",
    )

    load_loan_repayment = PythonOperator(
        task_id="load_silver_loan_repayment",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/loan_repayment.sql",
            "target_table": "silver.loan_repayment",
        },
    )

    wait_for_bronze_loan_repayment >> load_loan_repayment


    # ================================================================
    # CARD
    # ================================================================

    wait_for_bronze_card = bronze_sensor(
        "wait_for_bronze_card",
        "load_bronze_card",
    )

    load_card = PythonOperator(
        task_id="load_silver_card",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/card.sql",
            "target_table": "silver.card",
        },
    )

    wait_for_bronze_card >> load_card


    # ================================================================
    # ATM
    # ================================================================

    wait_for_bronze_atm = bronze_sensor(
        "wait_for_bronze_atm",
        "load_bronze_atm",
    )

    load_atm = PythonOperator(
        task_id="load_silver_atm",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/atm.sql",
            "target_table": "silver.atm",
        },
    )

    wait_for_bronze_atm >> load_atm


    # ================================================================
    # MERCHANT
    # ================================================================

    wait_for_bronze_merchant = bronze_sensor(
        "wait_for_bronze_merchant",
        "load_bronze_merchant",
    )

    load_merchant = PythonOperator(
        task_id="load_silver_merchant",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/merchant.sql",
            "target_table": "silver.merchant",
        },
    )

    wait_for_bronze_merchant >> load_merchant


    # ================================================================
    # TRANSACTION
    # ================================================================

    wait_for_bronze_transaction = bronze_sensor(
        "wait_for_bronze_transaction",
        "load_bronze_transaction",
    )

    load_transaction = PythonOperator(
        task_id="load_silver_transaction",
        python_callable=load_silver_table,
        op_kwargs={
            "sql_file": "silver/transaction.sql",
            "target_table": "silver.transaction",
        },
    )

    wait_for_bronze_transaction >> load_transaction


    # ================================================================
    # START
    # ================================================================

    start >> [
        wait_for_bronze_customer,
        wait_for_bronze_customer_address,
        wait_for_bronze_customer_phone,
        wait_for_bronze_branch,
        wait_for_bronze_employee,
        wait_for_bronze_account,
        wait_for_bronze_account_ownership,
        wait_for_bronze_loan,
        wait_for_bronze_loan_repayment,
        wait_for_bronze_card,
        wait_for_bronze_atm,
        wait_for_bronze_merchant,
        wait_for_bronze_transaction,
    ]