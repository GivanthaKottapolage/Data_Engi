import psycopg
from config import DB_CONFIG


def get_connection():
    return psycopg.connect(**DB_CONFIG)


def execute_sql_file(file_path):
    conn = get_connection()

    try:
        with conn.cursor() as cur:
            with open(file_path, "r") as f:
                sql = f.read()

            print(f"Executing {file_path}...")
            cur.execute(sql)
            conn.commit()

            print("Done")

    except Exception as e:
        conn.rollback()
        print(f"Failed: {e}")

    finally:
        conn.close()