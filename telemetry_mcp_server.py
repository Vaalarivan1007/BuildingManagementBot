import sys
import json
import pandas as pd
from schema_reader import SchemaReader
from sql_validator import validate_sql, format_sql
from llm_engine import LLMEngine

def handle_request(request):
    method = request.get("method")
    params = request.get("params", {})
    req_id = request.get("id")

    if method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "tools": [
                    {"name": "query_telemetry", "description": "Execute text-to-SQL telemetry query"}
                ]
            }
        }
    elif method == "tools/call":
        tool_name = params.get("name")
        args = params.get("arguments", {})
        
        if tool_name == "query_telemetry":
            try:
                natural_prompt = args.get("natural_prompt", "")
                host = args.get("host", "localhost")
                port = int(args.get("port", 3306))
                user = args.get("user", "root")
                password = args.get("password", "")
                database = args.get("database", "telemetry_db")

                reader = SchemaReader(host, port, user, password, database)
                reader.connect()
                schema_text = reader.build_schema_text()
                tables = reader.get_tables()

                engine = LLMEngine()
                engine.load()

                raw_sql = engine.generate_sql(natural_prompt, schema_text, history=[])
                clean_sql = validate_sql(raw_sql, tables)
                pretty_sql = format_sql(clean_sql)

                cursor = reader.conn.cursor(buffered=True)
                cursor.execute(clean_sql)
                rows = cursor.fetchmany(100)
                columns = [d[0] for d in cursor.description] if cursor.description else []
                cursor.close()

                df = pd.DataFrame(rows, columns=columns)
                res = json.dumps({
                    "status": "success",
                    "executed_sql": pretty_sql,
                    "data": df.to_dict(orient="records")
                })
            except Exception as e:
                res = json.dumps({"status": "error", "message": str(e)})
        else:
            res = "Unknown tool"

        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {"content": [{"type": "text", "text": str(res)}]}
        }

if __name__ == "__main__":
    for line in sys.stdin:
        if not line.strip():
            continue
        try:
            req = json.loads(line)
            resp = handle_request(req)
            sys.stdout.write(json.dumps(resp) + "\n")
            sys.stdout.flush()
        except Exception as e:
            sys.stderr.write(f"Error: {e}\n")