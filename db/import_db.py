"""将 schema.sql 和 seed.sql 导入本地 PostgreSQL 数据库。

用法:
    1. 安装驱动:  pip install psycopg2-binary
    2. 先创建数据库:  createdb careplan
       或:  psql -c "CREATE DATABASE careplan;"
    3. 运行:  python db/import_db.py

连接信息通过环境变量覆盖，默认值如下。
"""
import os
from pathlib import Path

import psycopg2

DB_NAME = os.getenv("POSTGRES_DB", "careplan")
DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
DB_HOST = os.getenv("POSTGRES_HOST", "localhost")
DB_PORT = os.getenv("POSTGRES_PORT", "5432")

BASE_DIR = Path(__file__).parent


def run_sql_file(cursor, path: Path) -> None:
    cursor.execute(path.read_text(encoding="utf-8"))
    print(f"已执行: {path.name}")


def main() -> None:
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
    )
    try:
        with conn.cursor() as cur:
            run_sql_file(cur, BASE_DIR / "schema.sql")
            run_sql_file(cur, BASE_DIR / "seed.sql")
        conn.commit()
        print("导入完成 ✓")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
