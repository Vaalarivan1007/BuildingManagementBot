"""
bms_tools.py - Streamlined 4-Tool Catalog for Building Management System (BMS)
Optimized for Qwen 2.5 Coder & Ollama Native Tool Calling (Zero Ambiguity & High Speed).
"""

from __future__ import annotations

import json
import os
import re
import sqlite3
import time
from typing import Any, Dict, List, Optional
import pandas as pd
from decimal import Decimal

# Local module imports
import opnsense_dryrun as opn
from sql_validator import validate_sql, format_sql, ValidationError

DEVICE_ALIASES = {
    "main unit": 1,
    "main": 1,
    "primary unit": 1,
    "primary panel": 1,
    "main panel": 1,
    "chiller": 1,
    "unit 1": 1,
    "device 1": 1,
    "subsystem 1": 1,
    "vineid 1": 1,
    "secondary unit": 2,
    "unit 2": 2,
    "device 2": 2,
    "subsystem 2": 2,
    "vineid 2": 2
}

def default_json_converter(o: Any) -> Any:
    if isinstance(o, Decimal):
        return float(o)
    if hasattr(o, "isoformat"):
        return o.isoformat()
    return str(o)

def resolve_device_alias(alias: Optional[str]) -> int:
    """Helper to map device names to numerical vineid."""
    if not alias:
        return 1
    clean = str(alias).lower().strip()
    if clean in DEVICE_ALIASES:
        return DEVICE_ALIASES[clean]
    
    # Try numeric extraction (e.g. "unit 3" -> 3, "vine 3" -> 3)
    m = re.search(r"\b(?:unit|device|panel|vine|vineid|subsystem)\s*#?\s*(\d+)\b", clean)
    if m:
        return int(m.group(1))

    # Try train_db memory lookup
    if os.path.exists("train_db.sqlite"):
        try:
            conn = sqlite3.connect("train_db.sqlite")
            cur = conn.cursor()
            cur.execute("SELECT memory_key, memory_value FROM agent_memory WHERE category = 'user_preference'")
            rows = cur.fetchall()
            conn.close()
            for k, v in rows:
                if clean in k.lower() or clean in v.lower():
                    vm = re.search(r"vineid\s*=?\s*(\d+)", v.lower())
                    if vm:
                        return int(vm.group(1))
        except Exception:
            pass
    return 1

# ---------------------------------------------------------------------------
# 1. TOOL IMPLEMENTATIONS
# ---------------------------------------------------------------------------

def query_telemetry(
    natural_request: str,
    sql_query: Optional[str] = None,
    device_alias: Optional[str] = None,
    is_chart_requested: bool = False,
    limit: int = 50,
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Executes relational SQL query against MySQL telemetry database (table: vinereadings).
    Handles vineid alias mapping (e.g. 'main unit' -> vineid 1), validation, and execution.
    """
    reader = context.get("reader") if context else None
    if not reader or not reader.conn:
        return {
            "status": "error",
            "message": "Database reader is not connected. Please connect to MySQL in the sidebar."
        }

    vid = resolve_device_alias(device_alias or natural_request)
    q_lower = natural_request.lower()

    # Formulate query if not provided
    if not sql_query or not sql_query.strip().lower().startswith("select"):
        v_clause = f"WHERE vineid = {vid}"
        if any(k in q_lower for k in ["voltage", "virv", "viyv", "vibv", "vinv"]):
            sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, virv, viyv, vibv, vinv, vibattery FROM vinereadings {v_clause} ORDER BY vidatetime DESC LIMIT {limit};"""
        elif any(k in q_lower for k in ["current", "viri", "viyi", "vibi", "imbalance"]):
            sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, viri, viyi, vibi, vicurrentimbalance, vitemp FROM vinereadings {v_clause} ORDER BY vidatetime DESC LIMIT {limit};"""
        elif any(k in q_lower for k in ["energy", "kwh", "power", "vienergy"]):
            sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, vienergy, virv, viri FROM vinereadings {v_clause} ORDER BY vidatetime DESC LIMIT {limit};"""
        elif any(k in q_lower for k in ["temp", "temperature", "thermal"]):
            sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, vitemp, vicurrentimbalance, viri, viyi, vibi FROM vinereadings {v_clause} ORDER BY vidatetime DESC LIMIT {limit};"""
        else:
            sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, virv, viyv, vibv, viri, viyi, vibi, vitemp, vicurrentimbalance, vibattery FROM vinereadings {v_clause} ORDER BY vidatetime DESC LIMIT {limit};"""
    else:
        sql = sql_query.strip()

    try:
        tables = reader.get_tables()
        clean_sql = validate_sql(sql, tables)
        pretty_sql = format_sql(clean_sql)

        conn = reader.conn
        if not conn.is_connected():
            reader.connect()
            conn = reader.conn

        cursor = conn.cursor(buffered=True)
        start = time.time()
        cursor.execute(clean_sql)
        rows = cursor.fetchmany(100)
        columns = [d[0] for d in cursor.description] if cursor.description else []
        cursor.close()
        elapsed = time.time() - start

        df = pd.DataFrame(rows, columns=columns)
        records = json.loads(json.dumps(df.to_dict(orient="records"), default=default_json_converter))

        # Check if chart was requested
        plot_keywords = ["plot", "trend", "graph", "chart", "draw", "visualize", "diagram"]
        should_plot = is_chart_requested or any(k in q_lower for k in plot_keywords)

        return {
            "status": "success",
            "vineid": vid,
            "executed_sql": pretty_sql,
            "time_taken": round(elapsed, 3),
            "row_count": len(rows),
            "columns": columns,
            "data": records,
            "should_plot": should_plot,
            "preview": df.head(10).to_string(index=False) if not df.empty else "Query ran successfully (0 rows returned)."
        }
    except ValidationError as ve:
        return {"status": "validation_error", "message": f"SQL validation failed: {ve}", "raw_sql": sql}
    except Exception as e:
        return {"status": "execution_error", "message": str(e), "raw_sql": sql}

def inspect_firewall_security(
    target_port: Optional[int] = None,
    action_type: str = "port_safety_audit",
    query: str = "",
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Audits network ports and firewall security rules using OPNsense dry-run inspection.
    Evaluates port risk (e.g. Port 69 TFTP, Port 3306 MySQL, Port 502 Modbus, Port 47808 BACnet, Port 3389 RDP).
    """
    p_num = target_port
    if p_num is None and query:
        pm = re.search(r"\b(?:port\s*[:#]?\s*|is\s+port\s+)(\d{1,5})\b", query.lower())
        if not pm:
            pm = re.search(r"\b(?:is\s+)?(\d{1,5})\s+(?:safe|secure|risky|open)\b", query.lower())
        if pm:
            p_num = int(pm.group(1))

    # 1. Port safety audit
    if p_num is not None:
        report = opn.inspect_port_detailed_dryrun(p_num, query)
        info = opn.get_port_info(p_num)
        return {
            "status": "success",
            "action": "port_safety_audit",
            "port": p_num,
            "target_port": p_num,
            "protocol": info.get("protocol", "TCP/UDP"),
            "service": info.get("service"),
            "risk_rating": info.get("risk"),
            "risk_level": info.get("risk"),
            "severity": info.get("severity"),
            "dryrun_report": report
        }

    # 2. Rule creation proposal
    if action_type == "propose_block" or any(k in query.lower() for k in ["block", "propose", "drop", "deny"]):
        proposal = opn.propose_block(query or "block port 3389")
        return {
            "status": "success",
            "action": "propose_block",
            "proposal_report": proposal
        }

    # 3. General firewall command (rules, states, services, etc.)
    out = opn.handle(query or "show firewall rules")
    return {
        "status": "success",
        "action": "firewall_command",
        "command": query,
        "dryrun_report": out
    }

def diagnose_equipment_hazards(
    vineid: Optional[int] = 1,
    lookback_records: int = 50,
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Audits latest sensor telemetry to detect equipment failure hazards:
    Current imbalance (>10%), thermal overheat (>60°C), voltage sags/swells (outside 210-250V),
    neutral potential (>15V), and low sensor battery (<3.4V).
    """
    vid = resolve_device_alias(str(vineid))
    sql = f"""SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, virv, viyv, vibv, vinv, viri, viyi, vibi, vicurrentimbalance, vitemp, vibattery FROM vinereadings WHERE vineid = {vid} ORDER BY vidatetime DESC LIMIT {lookback_records};"""

    res = query_telemetry(natural_request="equipment hazard inspection", sql_query=sql, device_alias=str(vid), context=context)
    if res.get("status") != "success":
        res["vineid"] = vid
        return res

    data = res.get("data", [])
    if not data:
        return {"status": "warning", "message": f"No telemetry records available for device vineid {vid}."}

    latest = data[0]
    anomalies = []
    health_score = 100

    temp = float(latest.get("vitemp") or 0)
    if temp > 60.0:
        health_score -= 35
        anomalies.append({
            "hazard": "THERMAL OVERHEAT HAZARD",
            "severity": "CRITICAL",
            "metric": f"vitemp = {temp}°C",
            "threshold": "> 60.0°C",
            "impact": "Severe risk of insulation breakdown, component damage, or electrical panel fire."
        })
    elif temp > 50.0:
        health_score -= 10
        anomalies.append({
            "hazard": "ELEVATED TEMPERATURE",
            "severity": "MODERATE",
            "metric": f"vitemp = {temp}°C",
            "threshold": "> 50.0°C",
            "impact": "Operating temperature higher than normal. Check enclosure ventilation."
        })

    imbalance = float(latest.get("vicurrentimbalance") or 0)
    if imbalance > 10.0:
        health_score -= 30
        anomalies.append({
            "hazard": "PHASE CURRENT IMBALANCE",
            "severity": "HIGH",
            "metric": f"vicurrentimbalance = {imbalance}%",
            "threshold": "> 10.0%",
            "impact": "Unequal phase load drawing. Can overheat windings and damage connected 3-phase motors."
        })

    for phase, col in [("R-Phase", "virv"), ("Y-Phase", "viyv"), ("B-Phase", "vibv")]:
        v = float(latest.get(col) or 0)
        if v < 210.0 and v > 0:
            health_score -= 15
            anomalies.append({
                "hazard": f"{phase} VOLTAGE SAG",
                "severity": "HIGH",
                "metric": f"{col} = {v}V",
                "threshold": "< 210V",
                "impact": "Brownout condition. Equipment stalling or power supply trip risk."
            })
        elif v > 250.0:
            health_score -= 15
            anomalies.append({
                "hazard": f"{phase} VOLTAGE SURGE",
                "severity": "HIGH",
                "metric": f"{col} = {v}V",
                "threshold": "> 250V",
                "impact": "Overvoltage condition. Risk of dielectric damage to sensitive electronics."
            })

    vinv = float(latest.get("vinv") or 0)
    if vinv > 15.0:
        health_score -= 20
        anomalies.append({
            "hazard": "HIGH NEUTRAL-TO-EARTH POTENTIAL",
            "severity": "HIGH",
            "metric": f"vinv = {vinv}V",
            "threshold": "> 15.0V",
            "impact": "Floating neutral or ground impedance fault. Shock hazard and erratic sensor readings."
        })

    batt = float(latest.get("vibattery") or 0)
    if batt < 3.4 and batt > 0:
        health_score -= 10
        anomalies.append({
            "hazard": "LOW SENSOR BATTERY",
            "severity": "LOW",
            "metric": f"vibattery = {batt}V",
            "threshold": "< 3.4V",
            "impact": "IoT sensor battery low. Telemetry transmission dropout imminent."
        })

    health_score = max(0, health_score)
    if health_score >= 85:
        overall_status = "HEALTHY / OPTIMAL"
    elif health_score >= 60:
        overall_status = "WARNING - MAINTENANCE REQUIRED"
    else:
        overall_status = "CRITICAL HAZARD - IMMEDIATE ACTION REQUIRED"

    return {
        "status": "success",
        "vineid": vid,
        "health_score": health_score,
        "overall_status": overall_status,
        "reading_date": latest.get("reading_date"),
        "reading_time": latest.get("reading_time"),
        "total_anomalies": len(anomalies),
        "anomalies": anomalies,
        "latest_snapshot": {
            "vitemp": temp,
            "vicurrentimbalance": imbalance,
            "virv": latest.get("virv"),
            "viyv": latest.get("viyv"),
            "vibv": latest.get("vibv"),
            "vinv": vinv,
            "vibattery": batt
        }
    }

def manage_memory_and_rules(
    action: str = "list",
    rule_key: str = "",
    rule_value: str = "",
    key: Optional[str] = None,
    value: Optional[str] = None,
    category: str = "user_preference",
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Stores or retrieves persistent agent memory rules and user preferences from train_db.sqlite.
    ONLY invoked when explicitly instructed to remember/save a preference or list learned rules.
    """
    final_key = key or rule_key or "Preference"
    final_value = value or rule_value or ""
    db_file = "train_db.sqlite"
    conn = sqlite3.connect(db_file)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS agent_memory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            memory_key TEXT NOT NULL,
            memory_value TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()

    act = action.lower().strip()
    if act in ["save", "set", "store"]:
        cur.execute("INSERT INTO agent_memory (category, memory_key, memory_value) VALUES (?, ?, ?)", (category, final_key, final_value))
        conn.commit()
        conn.close()
        return {"status": "success", "message": f"Saved preference to train_db: {final_value}"}
    elif act in ["list", "get", "read"]:
        cur.execute("SELECT id, category, memory_key, memory_value, timestamp FROM agent_memory ORDER BY id DESC")
        rows = cur.fetchall()
        conn.close()
        return {
            "status": "success",
            "rules_count": len(rows),
            "rules": [{"id": r[0], "category": r[1], "key": r[2], "value": r[3], "timestamp": r[4]} for r in rows]
        }
    elif act in ["delete", "remove"]:
        cur.execute("DELETE FROM agent_memory WHERE memory_key = ? OR id = ?", (rule_key, rule_key))
        conn.commit()
        conn.close()
        return {"status": "success", "message": f"Deleted rule '{rule_key}' from train_db."}

    conn.close()
    return {"status": "error", "message": f"Unknown memory action: {action}"}

# ---------------------------------------------------------------------------
# 2. STREAMLINED OLLAMA JSON SCHEMAS (4 NON-OVERLAPPING TOOLS)
# ---------------------------------------------------------------------------

TOOLS_SCHEMA = [
    {
        "type": "function",
        "function": {
            "name": "query_telemetry",
            "description": "Executes relational SQL queries against MySQL database (table: vinereadings). Used for retrieving phase voltages (virv/viyv/vibv), currents (viri/viyi/vibi), energy (vienergy), temperature (vitemp), device vineids (Main Unit = 1), and time-series historical data.",
            "parameters": {
                "type": "object",
                "properties": {
                    "natural_request": {
                        "type": "string",
                        "description": "The telemetry request details (e.g. 'latest phase voltages', 'show current readings for main unit', 'vine readings')."
                    },
                    "device_alias": {
                        "type": "string",
                        "description": "Device name or alias (e.g. 'main unit', 'chiller', 'unit 2'). Automatically resolves to vineid 1, 2, etc."
                    },
                    "is_chart_requested": {
                        "type": "boolean",
                        "description": "Set to true if user asked to plot, graph, chart, draw, or visualize telemetry."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of rows to retrieve (default 50)."
                    }
                },
                "required": ["natural_request"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "inspect_firewall_security",
            "description": "Audits network ports and firewall security rules using OPNsense dry-run inspection. Evaluates port risk (e.g. Port 69 TFTP, Port 3306 MySQL, Port 502 Modbus, Port 47808 BACnet, Port 3389 RDP) and simulates OPNsense REST API queries (rules, states, listening services, rule proposals).",
            "parameters": {
                "type": "object",
                "properties": {
                    "target_port": {
                        "type": "integer",
                        "description": "Target TCP/UDP port number to audit (e.g. 69, 3306, 502, 47808, 3389)."
                    },
                    "action_type": {
                        "type": "string",
                        "description": "Action type: 'port_safety_audit', 'propose_block', or 'firewall_command'."
                    },
                    "query": {
                        "type": "string",
                        "description": "User's security prompt (e.g. 'is port 69 safe', 'block port 3389', 'show firewall rules')."
                    }
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "diagnose_equipment_hazards",
            "description": "Audits latest sensor telemetry to detect equipment failure risks, thermal hazards (vitemp > 60°C), phase current imbalance (>10%), voltage sags/surges (outside 210-250V), neutral faults, and low battery. Computes 0-100% Health Score.",
            "parameters": {
                "type": "object",
                "properties": {
                    "vineid": {
                        "type": "integer",
                        "description": "Numerical device vineid (default 1 for Main Unit)."
                    },
                    "lookback_records": {
                        "type": "integer",
                        "description": "Number of historical snapshots to analyze (default 50)."
                    }
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "manage_memory_and_rules",
            "description": "Saves, retrieves, or deletes persistent user preferences, device aliases, or operational rules in train_db.sqlite. ONLY invoked when explicitly instructed to remember/save a preference or list learned rules.",
            "parameters": {
                "type": "object",
                "properties": {
                    "action": {
                        "type": "string",
                        "description": "Action: 'save', 'list', or 'delete'."
                    },
                    "rule_key": {
                        "type": "string",
                        "description": "Memory key or alias identifier."
                    },
                    "rule_value": {
                        "type": "string",
                        "description": "The exact preference or rule text to store."
                    }
                },
                "required": ["action"]
            }
        }
    }
]

TOOL_DISPATCHER = {
    "query_telemetry": query_telemetry,
    "inspect_firewall_security": inspect_firewall_security,
    "diagnose_equipment_hazards": diagnose_equipment_hazards,
    "manage_memory_and_rules": manage_memory_and_rules
}

def execute_tool(tool_name: str, arguments: Dict[str, Any], context: Optional[Dict] = None) -> Dict[str, Any]:
    """Universal executor for the 4 tools."""
    if tool_name not in TOOL_DISPATCHER:
        return {"status": "error", "message": f"Tool '{tool_name}' not found."}

    handler = TOOL_DISPATCHER[tool_name]
    try:
        import inspect
        sig = inspect.signature(handler)
        if "context" in sig.parameters:
            return handler(**arguments, context=context)
        return handler(**arguments)
    except Exception as e:
        return {"status": "error", "tool": tool_name, "message": str(e)}
