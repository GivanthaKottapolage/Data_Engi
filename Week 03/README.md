# Basic Python ETL Demo

## Overview

This project demonstrates a **very basic ETL (Extract, Transform, Load)** process using Python and PostgreSQL.

> **Note**
>
> This project is **not intended to be a production-ready ETL framework** or a representation of industry best practices. Its primary purpose is to help understand the fundamental concepts behind an ETL pipeline and how data moves from an OLTP database to an OLAP database.

The ETL process in this project simply:

1. Reads SQL scripts from a folder.
2. Executes them in sequence.
3. Builds analytical models in the target database.

As the project evolves, more features such as logging, configuration management, metadata management, scheduling, incremental loading, and orchestration will be introduced.

---

# Project Structure

```
etl-demo/
│
├── config.py
├── db.py
├── main.py
│
└── sql/
    ├── data_vault.sql
    ├── inmon.sql
    └── kimball.sql
```

---

# ETL Flow

```
        PostgreSQL (OLTP)
               │
               │
        SQL Scripts (Python)
               │
               ▼
        PostgreSQL (OLAP)
```

Python executes each SQL script sequentially.

---

# Prerequisites

* Python 3.10+
* PostgreSQL
* psycopg

Install Python dependencies:

```bash
pip install psycopg[binary]
```

---

# Database Setup

This project requires two PostgreSQL databases.

## OLTP Database

Contains the source transactional data.

Example:

```
Database Name : oltp
Port          : 5432
```

Import the provided OLTP schema and sample data before running the ETL.

---

## OLAP Database

Contains the analytical models created by the ETL.

Example:

```
Database Name : olap
Port          : 5433
```

Ensure the target database is empty before executing the ETL for the first time.

---

# Configuration

Update the database connection details in `config.py`.

Example:

```python
DB_CONFIG = {
    "host": "localhost",
    "port": 5433,
    "dbname": "olap",
    "user": "postgres",
    "password": "password"
}
```

If your SQL scripts use `dblink`, update the connection string inside the SQL files as well.

Example:

```sql
SELECT *
FROM dblink(
    'host=localhost port=5432 dbname=oltp user=postgres password=password',
    'SELECT * FROM customer'
);
```

---

# Running the ETL

Execute:

```bash
python main.py
```

Expected output:

```
Executing sql/data_vault.sql...
Done

Executing sql/inmon.sql...
Done

Executing sql/kimball.sql...
Done
```

---

# Scheduling the ETL

Instead of manually running the ETL, you can schedule it using your operating system.

## Ubuntu / Linux (Cron)

Open the cron editor:

```bash
crontab -e
```

Run every day at 2:00 AM:

```cron
0 2 * * * /usr/bin/python3 /path/to/project/main.py
```

Run every hour:

```cron
0 * * * * /usr/bin/python3 /path/to/project/main.py
```

Run every 5 minutes:

```cron
*/5 * * * * /usr/bin/python3 /path/to/project/main.py
```

Log output:

```cron
0 * * * * /usr/bin/python3 /path/to/project/main.py >> /path/to/project/etl.log 2>&1
```

List scheduled jobs:

```bash
crontab -l
```

---

## macOS (Cron)

macOS also supports `cron`.

Edit your cron jobs:

```bash
crontab -e
```

Example:

```cron
0 * * * * /usr/local/bin/python3 /Users/username/projects/etl-demo/main.py
```

If you're using a Python virtual environment, create a shell script to activate it before running the ETL and schedule that script instead.

---

## Windows (Task Scheduler)

1. Open **Task Scheduler**.
2. Select **Create Basic Task**.
3. Enter a task name (e.g., **Basic ETL**).
4. Choose the schedule (Daily, Weekly, etc.).
5. Select **Start a Program**.
6. Program:

   ```
   python.exe
   ```
7. Arguments:

   ```
   main.py
   ```
8. Start in:

   ```
   C:\Projects\etl-demo
   ```
9. Save the task.

Windows Task Scheduler will now execute the ETL automatically according to the configured schedule.

---

# Current Limitations

This project intentionally keeps the implementation simple.

It currently does **not** include:

* Logging
* Error notifications
* Incremental loading
* Configuration files (.env)
* Retry mechanisms
* Metadata management
* Data lineage
* Data quality validation
* Orchestration tools (Airflow, Prefect, etc.)

These features will be added in future iterations as the project grows.

---

# Future Improvements

Planned enhancements include:

* Environment-based configuration
* ETL execution logging
* Incremental data loading
* Metadata management (OpenMetadata)
* Data quality validation
* Scheduling improvements
* Email notifications
* Orchestration using Apache Airflow or Prefect

---

# Disclaimer

This project is designed for learning and demonstration purposes only. The implementation intentionally favors simplicity over completeness to help illustrate the core concepts of an ETL pipeline before introducing more advanced engineering practices.
