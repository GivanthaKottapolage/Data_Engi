from pathlib import Path

from db import execute_sql_file

SQL_DIR = Path("sql")

sql_files = sorted(SQL_DIR.glob("*.sql"))

for sql_file in sql_files:
    execute_sql_file(sql_file)