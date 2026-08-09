from datetime import datetime
from pathlib import Path
import sys

# --------------------------------------------------------------------
# Make sure the dags folder (or project root) is on the path
# BEFORE importing anything from utils
# --------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

from utils.database import extract_data, load_data
from utils.file import read_sql


# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------

SOURCE_CONN = "postgres_raw"
TARGET_CONN = "postgres_dw"

SQL_DIR = BASE_DIR / "sql" / "bronze"


# --------------------------------------------------------------------
# Get last watermark from Bronze
# --------------------------------------------------------------------

def get_last_watermark(target_table: str):

    sql = f"""
        SELECT
            GREATEST(
                MAX(created_at),
                MAX(updated_at)
            ) AS last_watermark
        FROM {target_table};
    """

    columns, rows = extract_data(
        conn_id=TARGET_CONN,
        sql=sql,
    )

    last_watermark = rows[0][0]

    print(
        f"Last watermark for {target_table}: "
        f"{last_watermark}"
    )

    return last_watermark


# --------------------------------------------------------------------
# Generic Bronze Incremental Loader
# --------------------------------------------------------------------

def load_bronze_table(sql_file: str, target_table: str):

    # --------------------------------------------------------------
    # Get the last successfully loaded timestamp from Bronze
    # --------------------------------------------------------------

    last_watermark = get_last_watermark(target_table)

    # --------------------------------------------------------------
    # Read incremental SQL template
    # --------------------------------------------------------------

    sql = read_sql(SQL_DIR / sql_file)

    # --------------------------------------------------------------
    # Replace watermark placeholder
    # --------------------------------------------------------------

    sql = sql.replace(
        "{{ last_watermark }}",
        str(last_watermark)
    )

    # --------------------------------------------------------------
    # Extract only new / changed records
    # --------------------------------------------------------------

    columns, rows = extract_data(
        conn_id=SOURCE_CONN,
        sql=sql,
    )

    # --------------------------------------------------------------
    # Append to Bronze
    # --------------------------------------------------------------

    if rows:

        load_data(
            conn_id=TARGET_CONN,
            table_name=target_table,
            columns=columns,
            rows=rows,
        )

        print(
            f"Loaded {len(rows)} incremental rows "
            f"into {target_table}"
        )

    else:

        print(
            f"No new or updated rows found "
            f"for {target_table}"
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
    dag_id="02_incremental_load_bronze",
    description="Incremental load from OLTP into Bronze",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    tags=["bronze", "incremental", "training", "medallion"],
) as dag:

    start = EmptyOperator(
        task_id="start"
    )

    load_customer = PythonOperator(
        task_id="load_bronze_customer",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/customer.sql",
            "target_table": "bronze.customer",
        },
    )

    load_customer_address = PythonOperator(
        task_id="load_bronze_customer_address",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/customer_address.sql",
            "target_table": "bronze.customer_address",
        },
    )

    load_customer_phone = PythonOperator(
        task_id="load_bronze_customer_phone",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/customer_phone.sql",
            "target_table": "bronze.customer_phone",
        },
    )

    load_branch = PythonOperator(
        task_id="load_bronze_branch",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/branch.sql",
            "target_table": "bronze.branch",
        },
    )

    load_employee = PythonOperator(
        task_id="load_bronze_employee",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/employee.sql",
            "target_table": "bronze.employee",
        },
    )

    load_account = PythonOperator(
        task_id="load_bronze_account",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/account.sql",
            "target_table": "bronze.account",
        },
    )

    load_account_ownership = PythonOperator(
        task_id="load_bronze_account_ownership",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/account_ownership.sql",
            "target_table": "bronze.account_ownership",
        },
    )

    load_loan = PythonOperator(
        task_id="load_bronze_loan",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/loan.sql",
            "target_table": "bronze.loan",
        },
    )

    load_loan_repayment = PythonOperator(
        task_id="load_bronze_loan_repayment",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/loan_repayment.sql",
            "target_table": "bronze.loan_repayment",
        },
    )

    load_card = PythonOperator(
        task_id="load_bronze_card",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/card.sql",
            "target_table": "bronze.card",
        },
    )

    load_atm = PythonOperator(
        task_id="load_bronze_atm",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/atm.sql",
            "target_table": "bronze.atm",
        },
    )

    load_merchant = PythonOperator(
        task_id="load_bronze_merchant",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/merchant.sql",
            "target_table": "bronze.merchant",
        },
    )

    load_transaction = PythonOperator(
        task_id="load_bronze_transaction",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "incremental_load/transaction.sql",
            "target_table": "bronze.transaction",
        },
    )

    end = EmptyOperator(
        task_id="end"
    )


    # --------------------------------------------------------------
    # Parallel execution
    # --------------------------------------------------------------

    start >> [
        load_customer,
        load_customer_address,
        load_customer_phone,
        load_branch,
        load_employee,
        load_account,
        load_account_ownership,
        load_loan,
        load_loan_repayment,
        load_card,
        load_atm,
        load_merchant,
        load_transaction,
    ] >> end