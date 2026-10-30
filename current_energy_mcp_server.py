import sys
import json
from decimal import Decimal
import pandas as pd
from schema_reader import SchemaReader
from sql_validator import validate_sql, format_sql
from llm_engine import LLMEngine

engine = None

def get_engine():
    global engine
    if engine is None:
        sys.stderr.write("• [Current & Thermal Agent] Loading LLM Engine...\n")
        sys.stderr.flush()
        engine = LLMEngine()
        engine.load()
    return engine

def default_converter(o):
    if isinstance(o, Decimal):
        return float(o)
    raise TypeError(f"Object of type {o.__class__.__name__} is not JSON serializable")

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
                    {"name": "query_current_energy", "description": "Query phase currents, thermal readings, and cumulative energy"}
                ]
            }
        }
    elif method == "tools/call":
        tool_name = params.get("name")
        args = params.get("arguments", {})
        
        if tool_name == "query_current_energy":
            try:
                natural_prompt = args.get("natural_prompt", "")
                host = args.get("host", "121.242.232.215")
                port = int(args.get("port", 3306))
                user = args.get("user", "intern01")
                password = args.get("password", "Intern01@Rouser#2026")
                database = args.get("database", "sunandjay")

                reader = SchemaReader(host, port, user, password, database)
                reader.connect()
                schema_text = reader.build_schema_text()
                tables = reader.get_tables()

                llm = get_engine()
                raw_sql = llm.generate_sql(natural_prompt, schema_text, history=[])
                clean_sql = validate_sql(raw_sql, tables)
                pretty_sql = format_sql(clean_sql)

                cursor = reader.conn.cursor(buffered=True)
                cursor.execute(clean_sql)
                rows = cursor.fetchmany(100)
                columns = [d[0] for d in cursor.description] if cursor.description else []
                cursor.close()

                df = pd.DataFrame(rows, columns=columns)
                records = df.to_dict(orient="records")
                data_json = json.dumps(records, default=default_converter)

                res = json.dumps({
                    "status": "success",
                    "executed_sql": pretty_sql,
                    "data": json.loads(data_json)
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

    return {"jsonrpc": "2.0", "id": req_id, "error": {"code": -32601, "message": "Method not found"}}

if __name__ == "__main__":
    while True:
        line = sys.stdin.readline()
        if not line:
            break
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
            resp = handle_request(req)
            sys.stdout.write(json.dumps(resp) + "\n")
            sys.stdout.flush()
        except Exception as e:
            err_resp = {"jsonrpc": "2.0", "id": None, "error": {"code": -32603, "message": str(e)}}
            sys.stdout.write(json.dumps(err_resp) + "\n")
            sys.stdout.flush()