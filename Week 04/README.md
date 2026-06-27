# Week 04 — Building a Star Schema: Facts & Dimensions

Zero to Data Engineer — Week 04. Take the XYZ Bank operational source from Week 02 (the `core_banking` OLTP tables) and build a proper **star schema** on top of it: a set of dimension tables, two fact tables, and the SQL that loads them. This is where the dimensional-modeling theory from Week 02 turns into a working analytics layer you can query.

## What's here

| File | What it is |
|------|------------|
| `fact_and_dim.sql` | **Schema (DDL)** — creates the `fact_and_dim` schema, the dimension tables (`dim_date`, `dim_branch`, `dim_customer`, `dim_account`, `dim_employee`, `dim_transaction_channel`), and the fact tables (`fact_customer_daily_snapshot`, `fact_customer_monthly_performance`). Run this first. |
| `ingest_dim_and_fact.sql` | **Load (DML)** — populates the dimensions (generates `dim_date`, copies the rest from `core_banking`) and builds the facts by aggregating `core_banking.transaction`. Run this second. |

The model has two grains:

- **`fact_customer_daily_snapshot`** — one row per customer / branch / account / day, with deposit and withdrawal totals, transaction counts (ATM, mobile, card), and the average transaction amount.
- **`fact_customer_monthly_performance`** — the daily snapshot rolled up to one row per customer / branch / month.

## Prerequisites

This week **builds on Week 02**. You need the XYZ Bank source data already loaded into a `core_banking` schema (see [Week 02](../Week%2002/README.md) and its `bank_table_create.sql` + Dataset). The Week 04 scripts read directly from `core_banking.*`.

- PostgreSQL
- The `core_banking` source schema from Week 02, loaded with the bank dataset
- The `dblink` extension enabled (`fact_and_dim.sql` uses it to create the database):

  ```sql
  CREATE EXTENSION IF NOT EXISTS dblink;
  ```
- Apache NiFi, with the **PostgreSQL JDBC driver** available to it:
  1. Download the PostgreSQL JDBC driver (e.g. `postgresql-42.7.x.jar`).
  2. Copy the JAR into NiFi's `lib` directory:

     ```bash
     cp postgresql-42.7.7.jar ~/opt/nifi-2.10.0/lib/
     ```

> More info is available in the prerequisites on the Week 04 LMS.

## Getting the files (clone the repo)

This is a **private** repo. You must be signed in to the GitHub account that was added to the bootcamp students team.

```bash
git clone https://github.com/zuucrew/dw-fundamentals-bootcamp.git
cd "dw-fundamentals-bootcamp/Week 04"
```

> Prefer no command line? On the repo page click the green **Code** button → **Download ZIP**, then unzip it.

## How to start

1. Make sure the Week 02 `core_banking` source is loaded in PostgreSQL.
2. Run `fact_and_dim.sql` to create the `fact_and_dim` schema and all dimension + fact tables.
3. Run `ingest_dim_and_fact.sql` to populate the dimensions and load both fact tables.
4. Query the facts — e.g. total monthly deposits per branch, or each customer's most active day — and compare how much easier the star schema makes these questions versus querying the raw OLTP tables.

---

*Zuu Crew — Machine Learning Academy*