from datetime import datetime
from airflow.sdk import dag
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

@dag(dag_id="03_sql_warehouse", start_date=datetime(2026,1,1), schedule="@daily", catchup=False)
def sql_warehouse():
    staging = SQLExecuteQueryOperator(
        task_id="load_staging", conn_id="warehouse",
        sql="INSERT INTO staging.transactions SELECT * FROM source.transactions;"
    )
    dimensions = SQLExecuteQueryOperator(
        task_id="load_dimensions", conn_id="warehouse",
        sql="INSERT INTO dim_customer SELECT DISTINCT customer_id, customer_name FROM staging.transactions;"
    )
    fact = SQLExecuteQueryOperator(
        task_id="load_fact", conn_id="warehouse",
        sql="INSERT INTO fact_transaction SELECT transaction_id, customer_id, amount FROM staging.transactions;"
    )
    staging >> dimensions >> fact

sql_warehouse()
