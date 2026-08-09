from datetime import datetime
from pathlib import Path
import sys

# --------------------------------------------------------------------
# Make sure the dags folder (or project root) is on the path
# BEFORE importing anything from utils
# --------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent          # .../dags
sys.path.insert(0, str(BASE_DIR))                   # so "utils" can be found

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

from utils.database import extract_data, truncate_table, load_data
from utils.file import read_sql

# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------
SOURCE_CONN = "postgres_raw"
TARGET_CONN = "postgres_dw"

# Project root is one level above the dags folder
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = Path(__file__).resolve().parent / "sql" / "bronze"


# --------------------------------------------------------------------
# Generic Bronze Loader
# --------------------------------------------------------------------
def load_bronze_table(sql_file: str, target_table: str):
    sql = read_sql(SQL_DIR / sql_file)

    columns, rows = extract_data(
        conn_id=SOURCE_CONN,
        sql=sql,
    )

    truncate_table(
        conn_id=TARGET_CONN,
        table_name=target_table,
    )

    load_data(
        conn_id=TARGET_CONN,
        table_name=target_table,
        columns=columns,
        rows=rows,
    )

    print(f"Loaded {len(rows)} rows into {target_table}")


# --------------------------------------------------------------------
# DAG
# --------------------------------------------------------------------
default_args = {
    "owner": "freshbank",
    "retries": 1,
}

with DAG(
    dag_id="01_load_bronze_layer",
    description="Load Bronze Layer",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
    tags=["bronze", "training", "medallion"],
) as dag:

    start = EmptyOperator(task_id="start")

    load_customer = PythonOperator(
        task_id="load_bronze_customer",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "customer.sql",
            "target_table": "bronze.customer",
        },
    )

    load_branch = PythonOperator(
        task_id="load_bronze_branch",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "branch.sql",
            "target_table": "bronze.branch",
        },
    )

    load_account = PythonOperator(
        task_id="load_bronze_account",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "account.sql",
            "target_table": "bronze.account",
        },
    )

    load_employee = PythonOperator(
        task_id="load_bronze_employee",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "employee.sql",
            "target_table": "bronze.employee",
        },
    )

    load_transaction = PythonOperator(
        task_id="load_bronze_transaction",
        python_callable=load_bronze_table,
        op_kwargs={
            "sql_file": "transaction.sql",
            "target_table": "bronze.transaction",
        },
    )

    end = EmptyOperator(task_id="end")

    start >> [
        load_customer,
        load_branch,
        load_account,
        load_employee,
        load_transaction,
    ] >> end