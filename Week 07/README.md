# Week 07 — Orchestration with Apache Airflow & Slowly Changing Dimensions

Zero to Data Engineer — Week 07. Two things come together this week. First, **orchestration**: the Week 03 Python ETL was a script you ran by hand — here the same idea becomes a scheduled, retryable, observable Airflow DAG. Second, **the Bronze layer and SCDs**: you land raw source data in a `bronze` schema, then look at the different ways a dimension can track change over time (SCD Type 0 through Type 4).

## What's here

| File | What it is |
|------|------------|
| `bronze_layer.sql` | **Bronze DDL** — creates the 13 landing tables in the `bronze` schema (`customer`, `customer_address`, `customer_phone`, `branch`, `employee`, `account`, `account_ownership`, `loan`, `loan_repayment`, `card`, `atm`, `merchant`, `transaction`). Every table carries the source columns plus `load_timestamp` and `source_system` — the two audit columns that make a landing zone traceable. |
| `SCD.sql` | **SCD dimension DDL** — six variants of `fact_and_dim.dim_customer`, one per strategy: `dim_customer_scd0` (never changes), `dim_customer_scd1` (overwrite), `dim_customer_scd2` (`effective_from` / `effective_to` / `is_current` / `version_number`), `dim_customer_scd3` (current + previous column pairs), and the Type 4 pair `dim_customer_current` + `dim_customer_history`. |
| `banking-airflow/` | **The Airflow project** — the `dags/` folder you point Airflow at. See below. |

### Inside `banking-airflow/dags/`

| File | What it is |
|------|------------|
| `01_hello_world_dag.py` | The smallest useful DAG: `start` → `hello_world` → `end`. Prove your Airflow install works and get familiar with the UI, task logs, and manual triggers before touching a database. |
| `01_load_bronze_layer.py` | The real pipeline. Fans out from `start` into five parallel table loads (`customer`, `branch`, `account`, `employee`, `transaction`), then converges on `end`. Each task reads its extract query, truncates the Bronze target, and reloads it. |
| `sql/bronze/*.sql` | One extract query per source table — a plain `SELECT` from `core_banking.*` that tacks on `CURRENT_TIMESTAMP AS load_timestamp` and `'CORE_BANKING' AS source_system`. All 13 are here; the DAG wires up five of them, and adding the rest is the exercise. |
| `utils/database.py` | The database helpers, built on `PostgresHook`: `extract_data()`, `truncate_table()`, `load_data()`. This is the **truncate-and-reload** pattern — simple, idempotent, and fine at this data size. |
| `utils/file.py` | `read_sql()` — reads a `.sql` file off disk so queries live in files, not in Python strings. |

## Prerequisites

This week **builds on Week 02 and Week 04**. You need the XYZ Bank operational data already loaded into a `core_banking` schema (see [Week 02](../Week%2002/README.md)), and the `fact_and_dim` schema from [Week 04](../Week%2004/README.md) if you want to run `SCD.sql`.

- PostgreSQL, with the `core_banking` source schema loaded
- Python 3.11
- Apache Airflow with the PostgreSQL provider:

  ```bash
  pip install "apache-airflow" "apache-airflow-providers-postgres"
  ```

- Two **Airflow connections**, created in the UI under *Admin → Connections* (the DAG looks them up by ID):

  | Conn Id | Points at |
  |---------|-----------|
  | `postgres_raw` | the source database holding `core_banking` |
  | `postgres_dw` | the warehouse database holding `bronze` |

> More info is available in the prerequisites on the Week 07 LMS.

## Getting the files (clone the repo)

This is a **private** repo. You must be signed in to the GitHub account that was added to the bootcamp students team.

```bash
git clone https://github.com/zuucrew/dw-fundamentals-bootcamp.git
cd "dw-fundamentals-bootcamp/Week 07"
```

> Prefer no command line? On the repo page click the green **Code** button → **Download ZIP**, then unzip it.

## How to start

1. **Create the Bronze schema and tables.** `bronze_layer.sql` creates the tables but not the schema, so create that first:

   ```sql
   CREATE SCHEMA IF NOT EXISTS bronze;
   ```

   Then run `bronze_layer.sql`.

2. **Start Airflow** and point it at this project's `dags` folder:

   ```bash
   export AIRFLOW_HOME=$(pwd)/banking-airflow
   airflow standalone
   ```

   Open <http://localhost:8080> and sign in with the credentials it prints.

3. **Run `01_hello_world` first.** Trigger it manually and read the task log — confirm Airflow is healthy before you point it at a database.

4. **Add the two connections** (`postgres_raw`, `postgres_dw`) under *Admin → Connections*.

5. **Run `01_load_bronze_layer`.** Watch the five loads run in parallel in the graph view, then check the row counts:

   ```sql
   SELECT COUNT(*) FROM bronze.customer;
   ```

   Trigger it a second time — because each task truncates before loading, the counts stay the same. That's what makes the DAG safe to re-run.

6. **Extend it.** Eight extract queries in `sql/bronze/` aren't wired into the DAG yet. Add tasks for them.

7. **Run `SCD.sql`** and compare the six dimension designs. For a customer who moves city, ask what each table can still tell you afterwards: Type 1 has forgotten the old city, Type 2 has both rows with date ranges, Type 3 has exactly one previous value, Type 4 keeps the current row lean and pushes history to a side table.

---

*Zuu Crew — Machine Learning Academy*
