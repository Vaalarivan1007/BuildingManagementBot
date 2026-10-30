from __future__ import annotations
import mysql.connector
from mysql.connector import Error

class SchemaReader:
    def __init__(self, host: str, port: int, user: str, password: str, database: str):
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.database = database
        self.conn = None

    def connect(self):
        self.conn = mysql.connector.connect(
            host=self.host,
            port=self.port,
            user=self.user,
            password=self.password,
            database=self.database,
            connection_timeout=10,
        )
        return self.conn

    def close(self):
        if self.conn and self.conn.is_connected():
            self.conn.close()

    def get_tables(self) -> list[str]:
        cursor = self.conn.cursor(buffered=True)
        cursor.execute("SHOW TABLES;")
        tables = [row[0] for row in cursor.fetchall()]
        cursor.close()
        return tables

    def get_columns(self, table: str) -> list[tuple]:
        cursor = self.conn.cursor(buffered=True)
        cursor.execute(
            """
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s
            ORDER BY ORDINAL_POSITION;
            """,
            (self.database, table),
        )
        cols = cursor.fetchall()
        cursor.close()
        return cols

    def get_foreign_keys(self, table: str) -> list[tuple]:
        cursor = self.conn.cursor(buffered=True)
        cursor.execute(
            """
            SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s
              AND REFERENCED_TABLE_NAME IS NOT NULL;
            """,
            (self.database, table),
        )
        fks = cursor.fetchall()
        cursor.close()
        return fks

    def build_schema_text(self) -> str:
        tables = self.get_tables()
        lines = []
        for table in tables:
            cols = self.get_columns(table)
            col_strs = []
            for name, dtype, nullable, key in cols:
                tag = ""
                if key == "PRI":
                    tag = " [PK]"
                elif key == "MUL":
                    tag = " [FK]"
                col_strs.append(f"{name} {dtype}{tag}")
            lines.append(f"TABLE {table} ({', '.join(col_strs)})")
            fks = self.get_foreign_keys(table)
            for col, ref_table, ref_col in fks:
                lines.append(f"  -- FOREIGN KEY: {table}.{col} -> {ref_table}.{ref_col}")
        return "\n".join(lines)

    def get_numeric_columns(self, table: str) -> list[str]:
        numeric_types = {
            "int", "bigint", "smallint", "tinyint", "mediumint",
            "decimal", "float", "double", "numeric",
        }
        cols = self.get_columns(table)
        return [name for name, dtype, *_ in cols if dtype.lower() in numeric_types]

    def get_schema_dict(self) -> dict:
        tables = self.get_tables()
        schema = {}
        for table in tables:
            schema[table] = {
                "columns": self.get_columns(table),
                "foreign_keys": self.get_foreign_keys(table),
            }
        return schema