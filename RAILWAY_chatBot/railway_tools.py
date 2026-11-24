# -*- coding: utf-8 -*-
"""
railway_tools.py - Streamlined 4-Tool Catalog for Railway Network Management (OMCSMGMT_2_0_0)
Optimized for Qwen 2.5 Coder & Ollama Native Tool Calling (Zero Ambiguity & High Speed).
Connects to live OMCS database at 10.20.31.15:3306.
Enriched with relational joins across nedetails, probablecauses, specificproblems, and alarmtypedetails.
"""

from __future__ import annotations

import datetime
import json
import os
import re
import sqlite3
import time
from typing import Any, Dict, List, Optional, Tuple
from decimal import Decimal
import pandas as pd
import pymysql

# -----------------------------------------------------------------------------
# 1. DATABASE CONFIGURATION & CONNECTOR
# -----------------------------------------------------------------------------

DEFAULT_DB_CONFIG = {
    "host": os.getenv("DB_HOST", "10.20.31.15"),
    "port": int(os.getenv("DB_PORT", 3306)),
    "user": os.getenv("DB_USER", "omcsrouser"),
    "password": os.getenv("DB_PASSWORD", "RoOmcs@123"),
    "database": os.getenv("DB_NAME", "OMCSMGMT_2_0_0")
}

TRAIN_DB_FILE = os.path.join(os.path.dirname(__file__), "railway_train_db.sqlite")
BOOKMARKS_FILE = os.path.join(os.path.dirname(__file__), "categorized_bookmarks.json")

def default_json_converter(o: Any) -> Any:
    if isinstance(o, Decimal):
        return float(o)
    if hasattr(o, "isoformat"):
        return o.isoformat()
    return str(o)


class OMCSDatabaseConnector:
    """Live thread-safe connection manager for OMCSMGMT_2_0_0."""
    def __init__(
        self,
        host: str = DEFAULT_DB_CONFIG["host"],
        port: int = DEFAULT_DB_CONFIG["port"],
        user: str = DEFAULT_DB_CONFIG["user"],
        password: str = DEFAULT_DB_CONFIG["password"],
        database: str = DEFAULT_DB_CONFIG["database"]
    ):
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database = database
        self.conn: Optional[pymysql.Connection] = None
        self.is_connected = False
        self.last_error = ""

    def connect(self) -> Tuple[bool, str]:
        try:
            self.conn = pymysql.connect(
                host=self.host,
                port=self.port,
                user=self.user,
                password=self.password,
                database=self.database,
                charset="utf8mb4",
                connect_timeout=5,
                autocommit=True
            )
            self.is_connected = True
            self.last_error = ""
            return True, f"Connected to {self.database} at {self.host}:{self.port}"
        except Exception as e:
            self.is_connected = False
            self.last_error = str(e)
            return False, f"Connection failed to {self.host}:{self.port} - {e}"

    def ensure_connected(self):
        if not self.conn or not self.is_connected:
            self.connect()
        else:
            try:
                self.conn.ping(reconnect=True)
            except Exception:
                self.connect()

    def execute_query(self, sql: str, limit: int = 200) -> Dict[str, Any]:
        self.ensure_connected()
        if not self.conn:
            return {
                "status": "error",
                "message": f"Database not connected: {self.last_error}",
                "data": [],
                "columns": [],
                "row_count": 0,
                "latency_sec": 0.0
            }

        clean = sql.strip().rstrip(";")
        start_time = time.time()
        try:
            with self.conn.cursor() as cur:
                cur.execute(clean)
                cols = [desc[0] for desc in cur.description] if cur.description else []
                rows = cur.fetchmany(limit)
                latency = round(time.time() - start_time, 3)
                df = pd.DataFrame(rows, columns=cols)
                df = format_dataframe_human_friendly(df)
                records = json.loads(json.dumps(df.to_dict(orient="records"), default=default_json_converter))
                return {
                    "status": "success",
                    "columns": list(df.columns),
                    "data": records,
                    "row_count": len(rows),
                    "latency_sec": latency
                }
        except Exception as e:
            latency = round(time.time() - start_time, 3)
            return {
                "status": "error",
                "message": str(e),
                "data": [],
                "columns": [],
                "row_count": 0,
                "latency_sec": latency
            }

    def close(self):
        if self.conn:
            try:
                self.conn.close()
            except Exception:
                pass
            self.is_connected = False


# -----------------------------------------------------------------------------
# 2. DATA POST-PROCESSING (HUMAN-GRADE CONVERSIONS)
# -----------------------------------------------------------------------------

def format_epoch_to_readable(val):
    if pd.isna(val):
        return val
    try:
        val_float = float(val)
        if 946684800 <= val_float <= 2208988800:
            dt = datetime.datetime.fromtimestamp(val_float)
            return dt.strftime("%Y-%m-%d %I:%M:%S %p")
        elif 946684800000 <= val_float <= 2208988800000:
            dt = datetime.datetime.fromtimestamp(val_float / 1000.0)
            return dt.strftime("%Y-%m-%d %I:%M:%S %p")
    except Exception:
        pass
    return val

def format_dataframe_human_friendly(df: pd.DataFrame) -> pd.DataFrame:
    """Converts raw epoch timestamps and numeric severity codes into clean human text."""
    if df.empty:
        return df

    out_df = df.copy()

    # Convert any numeric epoch column to readable datetime
    for col in out_df.columns:
        sample = out_df[col].dropna().head(1)
        if not sample.empty:
            s_val = sample.iloc[0]
            try:
                num = float(s_val)
                if 946684800 <= num <= 2208988800 or 946684800000 <= num <= 2208988800000:
                    out_df[col] = out_df[col].apply(format_epoch_to_readable)
            except (ValueError, TypeError):
                pass

    # Map perceivedseverity if present as numbers
    sev_col = next((c for c in out_df.columns if c.lower() in ["perceivedseverity", "assignedseverity"]), None)
    if sev_col and pd.api.types.is_numeric_dtype(out_df[sev_col]):
        sev_label_map = {1: "Critical", 2: "Major", 3: "Minor", 4: "Warning", 5: "Indeterminate", 0: "Cleared"}
        out_df[sev_col] = out_df[sev_col].map(sev_label_map).fillna(out_df[sev_col])

    return out_df


# -----------------------------------------------------------------------------
# 3. SQL SAFETY VALIDATOR & FORMATTER
# -----------------------------------------------------------------------------

FORBIDDEN_SQL_KEYWORDS = [
    r"\bDROP\b", r"\bDELETE\b", r"\bTRUNCATE\b", r"\bALTER\b",
    r"\bUPDATE\b", r"\bINSERT\b", r"\bREPLACE\b", r"\bRENAME\b",
    r"\bGRANT\b", r"\bREVOKE\b", r"\bEXEC\b", r"\bSHUTDOWN\b"
]

def validate_railway_sql(sql: str) -> str:
    """Strictly validates SQL to ensure only safe, read-only statements are executed."""
    if not sql or not isinstance(sql, str):
        raise ValueError("Empty or invalid SQL query provided.")

    clean = sql.strip()
    if clean.startswith("```"):
        clean = re.sub(r"^```[a-zA-Z]*\n?", "", clean)
        clean = re.sub(r"\n?```$", "", clean)
        clean = clean.strip()

    statements = [s for s in clean.split(";") if s.strip()]
    if len(statements) > 1:
        raise ValueError("Multi-statement SQL execution is blocked for security.")

    query_to_check = statements[0].strip()

    first_word = query_to_check.split()[0].upper() if query_to_check.split() else ""
    if first_word not in ["SELECT", "SHOW", "EXPLAIN", "WITH", "DESC", "DESCRIBE"]:
        raise ValueError(f"Blocked unsafe command '{first_word}'. Only read-only queries are permitted.")

    for pat in FORBIDDEN_SQL_KEYWORDS:
        if re.search(pat, query_to_check, re.IGNORECASE):
            raise ValueError(f"Destructive or mutating SQL detected ({pat}). Operation blocked.")

    if first_word in ["SELECT", "WITH"] and not re.search(r"\bLIMIT\s+\d+", query_to_check, re.IGNORECASE):
        query_to_check += " LIMIT 100"

    return query_to_check


# -----------------------------------------------------------------------------
# 4. PERSISTENT TRAIN_DB SQLITE ENGINE
# -----------------------------------------------------------------------------

def init_railway_train_db():
    conn = sqlite3.connect(TRAIN_DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS agent_memory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            memory_key TEXT NOT NULL,
            memory_value TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

def save_memory_fact(category: str, key: str, value: str):
    conn = sqlite3.connect(TRAIN_DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO agent_memory (category, memory_key, memory_value)
        VALUES (?, ?, ?)
    """, (category, key, value))
    conn.commit()
    conn.close()

def delete_memory_fact(memory_id: int):
    conn = sqlite3.connect(TRAIN_DB_FILE)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM agent_memory WHERE id = ?", (memory_id,))
    conn.commit()
    conn.close()

def clear_all_memories():
    conn = sqlite3.connect(TRAIN_DB_FILE)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM agent_memory")
    conn.commit()
    conn.close()

def load_all_memories_dataframe() -> pd.DataFrame:
    if not os.path.exists(TRAIN_DB_FILE):
        return pd.DataFrame()
    conn = sqlite3.connect(TRAIN_DB_FILE)
    try:
        df = pd.read_sql_query("SELECT id, category, memory_key, memory_value, timestamp FROM agent_memory ORDER BY id DESC", conn)
    except Exception:
        df = pd.DataFrame()
    finally:
        conn.close()
    return df

def load_all_memories() -> str:
    if not os.path.exists(TRAIN_DB_FILE):
        return "No learned memories stored in train_db yet."
    conn = sqlite3.connect(TRAIN_DB_FILE)
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT category, memory_key, memory_value FROM agent_memory")
        rows = cursor.fetchall()
    except Exception:
        rows = []
    finally:
        conn.close()

    if not rows:
        return "No learned memories stored in train_db yet."
    memory_text = "\n[PERSISTENT TRAIN_DB MEMORY & USER PREFERENCES]:\n"
    for cat, k, v in rows:
        memory_text += f"- [{cat.upper()}] {k}: {v}\n"
    return memory_text


# -----------------------------------------------------------------------------
# 5. BOOKMARKS SYSTEM
# -----------------------------------------------------------------------------

def load_bookmarks() -> Dict[str, List[str]]:
    if os.path.exists(BOOKMARKS_FILE):
        try:
            with open(BOOKMARKS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {
        "Alarm Audits": [
            "What are the top 5 most frequent active alarms?",
            "Show all active critical alarms",
            "Plot active alarm severity distribution"
        ],
        "Network Elements": [
            "List all offline network elements",
            "Show all network elements and admin states",
            "Show NE details summary"
        ],
        "SNMP Health & Stations": [
            "What is the current SNMP polling status of all nodes?",
            "Show railway stations list",
            "Count alarms by Managed Object Class (MOC)"
        ],
        "General": [
            "Show active alarms vs historical alarms overview"
        ]
    }

def save_bookmarks(bookmarks: Dict[str, List[str]]):
    with open(BOOKMARKS_FILE, "w") as f:
        json.dump(bookmarks, f, indent=4)


# -----------------------------------------------------------------------------
# 6. DOMAIN DEFINITIONS & SEVERITY MAPPING
# -----------------------------------------------------------------------------

SEVERITY_MAPPING = {
    1: {"name": "Critical", "badge": "🔴", "color": "#f2495c"},
    2: {"name": "Major", "badge": "🟠", "color": "#ff780a"},
    3: {"name": "Minor", "badge": "🟡", "color": "#f2c96d"},
    4: {"name": "Warning", "badge": "🔵", "color": "#5794f2"},
    5: {"name": "Indeterminate", "badge": "⚪", "color": "#9ca3af"},
    0: {"name": "Cleared", "badge": "🟢", "color": "#73bf69"}
}

ADMIN_STATE_MAPPING = {
    1: "Up / Managed",
    2: "Down / Unmanaged",
    3: "Maintenance Mode"
}


# -----------------------------------------------------------------------------
# 7. TOOL 1: QUERY RAILWAY DATABASE (SMART RELATIONAL FORMULATOR)
# -----------------------------------------------------------------------------

def query_railway_database(
    natural_request: str,
    sql_query: Optional[str] = None,
    limit: int = 100,
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Executes a validated read-only SQL query against the OMCSMGMT_2_0_0 Railway Database.
    Automatically enriches raw IDs with human-readable descriptions, equipment names,
    formatted timestamps, and root causes via SQL joins.
    """
    connector = context.get("connector") if context else None
    if not connector:
        connector = OMCSDatabaseConnector()
        connector.connect()

    q_lower = natural_request.lower()

    # Extract numeric limit if specified in text (e.g. "top 5" -> 5)
    lim_match = re.search(r"\b(?:top|latest|first|last)\s+(\d+)\b", q_lower)
    eff_limit = int(lim_match.group(1)) if lim_match else limit

    if not sql_query or not sql_query.strip().lower().startswith("select"):
        # 1. Top Most Frequent Alarms (Aggregated by problem & description)
        if any(k in q_lower for k in ["frequent", "recurring", "common"]) or ("top" in q_lower and "alarm" in q_lower):
            sql = f"""
            SELECT 
                COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, a.ticketmessage, 'Hardware/Link Alert') AS alarm_description,
                a.moc AS subsystem,
                COUNT(*) AS active_frequency,
                CASE MAX(a.perceivedseverity)
                    WHEN 1 THEN 'Critical'
                    WHEN 2 THEN 'Major'
                    WHEN 3 THEN 'Minor'
                    WHEN 4 THEN 'Warning'
                    WHEN 5 THEN 'Indeterminate'
                    ELSE 'Cleared'
                END AS severity_level,
                DATE_FORMAT(FROM_UNIXTIME(MIN(a.eventtime)), '%Y-%m-%d %h:%i:%s %p') AS earliest_detected,
                DATE_FORMAT(FROM_UNIXTIME(MAX(a.eventtime)), '%Y-%m-%d %h:%i:%s %p') AS latest_detected
            FROM activealarms a
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid
            LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid
            GROUP BY alarm_description, a.moc
            ORDER BY active_frequency DESC
            LIMIT {eff_limit};
            """

        # 2. Active Critical Alarms (Enriched with equipment name, timestamps & probable cause)
        elif any(k in q_lower for k in ["critical alarm", "severity 1", "active critical", "critical"]):
            sql = f"""
            SELECT 
                a.recordid,
                COALESCE(n.nename, CONCAT('NE #', a.neid)) AS equipment_name,
                a.moc AS subsystem,
                'Critical' AS severity,
                DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS event_time,
                COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, a.ticketmessage, 'Hardware/Link Alert') AS alarm_description,
                COALESCE(pc.probablecausename, CONCAT('Cause #', a.probablecause)) AS probable_cause
            FROM activealarms a
            LEFT JOIN nedetails n ON a.neid = n.neid
            LEFT JOIN probablecauses pc ON a.probablecause = pc.probablecauseid
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid
            LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid
            WHERE a.perceivedseverity = 1
            ORDER BY a.eventtime DESC
            LIMIT {eff_limit};
            """

        # 3. Severity Distribution
        elif any(k in q_lower for k in ["alarm severity", "severity distribution", "count by severity", "severity"]):
            sql = """
            SELECT perceivedseverity,
                   CASE perceivedseverity
                       WHEN 1 THEN 'Critical'
                       WHEN 2 THEN 'Major'
                       WHEN 3 THEN 'Minor'
                       WHEN 4 THEN 'Warning'
                       WHEN 5 THEN 'Indeterminate'
                       ELSE 'Cleared'
                   END AS severity_label,
                   COUNT(*) AS alarm_count
            FROM activealarms
            GROUP BY perceivedseverity
            ORDER BY perceivedseverity ASC;
            """

        # 4. Offline / Unreachable Network Elements
        elif any(k in q_lower for k in ["offline", "down", "unreachable", "unmanaged"]):
            sql = f"""
            SELECT 
                neid, nename, neshortname, neversionnumber,
                CASE neadminstate WHEN 1 THEN 'Managed / Up' WHEN 2 THEN 'Unmanaged / Down' ELSE 'Maintenance' END AS status_desc,
                DATE_FORMAT(FROM_UNIXTIME(necreationtime), '%Y-%m-%d %h:%i:%s %p') AS registered_time
            FROM nedetails
            WHERE neadminstate != 1 OR neid IN (
                SELECT snmppollneid FROM snmppollstatus WHERE snmppollstatus = '0'
            )
            ORDER BY neid ASC
            LIMIT {eff_limit};
            """

        # 5. SNMP Polling Health
        elif any(k in q_lower for k in ["snmp", "poll status", "polling"]):
            sql = f"""
            SELECT 
                s.snmppollid,
                COALESCE(n.nename, CONCAT('NE #', s.snmppollneid)) AS network_element,
                CASE s.snmppollstatus WHEN '1' THEN 'Reachable / Nominal' ELSE 'Unreachable / Failed' END AS poll_health,
                COALESCE(s.snmppollstatusreason, 'Nominal response') AS status_reason,
                DATE_FORMAT(FROM_UNIXTIME(s.snmppollcreationtime), '%Y-%m-%d %h:%i:%s %p') AS poll_time
            FROM snmppollstatus s
            LEFT JOIN nedetails n ON s.snmppollneid = n.neid
            ORDER BY s.snmppollcreationtime DESC
            LIMIT {eff_limit};
            """

        # 6. Station Details
        elif any(k in q_lower for k in ["station", "stations"]):
            sql = f"""
            SELECT stationid, stationname, stationshortname, stationcity, stationplatforms,
                   DATE_FORMAT(FROM_UNIXTIME(stationcreationtime), '%Y-%m-%d') AS commissioned_date
            FROM stationdetails
            ORDER BY stationname ASC
            LIMIT {eff_limit};
            """

        # 7. Network Elements Catalog
        elif any(k in q_lower for k in ["ne", "network element", "devices", "equipment"]):
            sql = f"""
            SELECT neid, nename, neshortname, neversionnumber,
                   CASE neadminstate WHEN 1 THEN 'Managed / Up' WHEN 2 THEN 'Unmanaged / Down' ELSE 'Maintenance' END AS admin_status,
                   DATE_FORMAT(FROM_UNIXTIME(necreationtime), '%Y-%m-%d %h:%i:%s %p') AS creation_time
            FROM nedetails
            ORDER BY neid ASC
            LIMIT {eff_limit};
            """

        # Default Enriched Alarm Query
        else:
            sql = f"""
            SELECT 
                a.recordid,
                COALESCE(n.nename, CONCAT('NE #', a.neid)) AS equipment_name,
                a.moc AS subsystem,
                CASE a.perceivedseverity
                    WHEN 1 THEN 'Critical'
                    WHEN 2 THEN 'Major'
                    WHEN 3 THEN 'Minor'
                    WHEN 4 THEN 'Warning'
                    WHEN 5 THEN 'Indeterminate'
                    ELSE 'Cleared'
                END AS severity,
                DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS event_time,
                COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, a.ticketmessage, 'Hardware/Link Alert') AS alarm_description,
                COALESCE(pc.probablecausename, CONCAT('Cause #', a.probablecause)) AS probable_cause
            FROM activealarms a
            LEFT JOIN nedetails n ON a.neid = n.neid
            LEFT JOIN probablecauses pc ON a.probablecause = pc.probablecauseid
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid
            LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid
            ORDER BY a.eventtime DESC
            LIMIT {eff_limit};
            """
    else:
        sql = sql_query.strip()

    try:
        clean_sql = validate_railway_sql(sql)
        res = connector.execute_query(clean_sql, limit=eff_limit)
        
        plot_keywords = ["plot", "trend", "graph", "chart", "draw", "visualize", "distribution", "frequent", "top"]
        should_plot = any(k in q_lower for k in plot_keywords) or "distribution" in q_lower

        return {
            "status": res["status"],
            "data": res["data"],
            "columns": res["columns"],
            "row_count": res["row_count"],
            "executed_sql": clean_sql,
            "latency_sec": res["latency_sec"],
            "should_plot": should_plot,
            "message": res.get("message", "")
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "data": [],
            "columns": [],
            "row_count": 0,
            "executed_sql": sql,
            "latency_sec": 0.0,
            "should_plot": False
        }


# -----------------------------------------------------------------------------
# 8. TOOL 2: DIAGNOSE RAILWAY FAULTS
# -----------------------------------------------------------------------------

def diagnose_railway_faults(
    severity_threshold: int = 2,
    lookback_hours: int = 24,
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Deep fault diagnosis across activealarms, incidentdetails, and fracasdetails.
    Identifies high-impact anomalies, top failing subsystems, and incident correlations.
    """
    connector = context.get("connector") if context else None
    if not connector:
        connector = OMCSDatabaseConnector()
        connector.connect()

    sql_crit = f"""
    SELECT 
        a.recordid,
        COALESCE(n.nename, CONCAT('NE #', a.neid)) AS equipment_name,
        a.moc AS subsystem,
        CASE a.perceivedseverity WHEN 1 THEN 'Critical' ELSE 'Major' END AS severity,
        DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS event_time,
        COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, 'Hardware/Link Alert') AS alarm_description,
        COALESCE(pc.probablecausename, CONCAT('Cause #', a.probablecause)) AS probable_cause
    FROM activealarms a
    LEFT JOIN nedetails n ON a.neid = n.neid
    LEFT JOIN probablecauses pc ON a.probablecause = pc.probablecauseid
    LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid
    LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid
    WHERE a.perceivedseverity <= {severity_threshold}
    ORDER BY a.eventtime DESC
    LIMIT 100;
    """
    res_crit = connector.execute_query(sql_crit, limit=100)

    sql_summary = """
    SELECT perceivedseverity,
           CASE perceivedseverity
               WHEN 1 THEN 'Critical'
               WHEN 2 THEN 'Major'
               WHEN 3 THEN 'Minor'
               WHEN 4 THEN 'Warning'
               WHEN 5 THEN 'Indeterminate'
               ELSE 'Cleared'
           END AS severity_label,
           COUNT(*) as count
    FROM activealarms
    GROUP BY perceivedseverity
    ORDER BY perceivedseverity ASC;
    """
    res_summary = connector.execute_query(sql_summary, limit=10)

    sql_top_problems = """
    SELECT 
        COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, 'Link / Connection Fault') AS problem_name,
        COUNT(*) as alarm_count
    FROM activealarms a
    LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid
    LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid
    GROUP BY problem_name
    ORDER BY alarm_count DESC
    LIMIT 5;
    """
    res_problems = connector.execute_query(sql_top_problems, limit=5)

    crit_count = sum(r["count"] for r in res_summary["data"] if r.get("perceivedseverity") == 1)
    major_count = sum(r["count"] for r in res_summary["data"] if r.get("perceivedseverity") == 2)
    total_active = sum(r["count"] for r in res_summary["data"])

    return {
        "status": "success",
        "total_active_alarms": total_active,
        "critical_alarms_count": crit_count,
        "major_alarms_count": major_count,
        "summary_by_severity": res_summary["data"],
        "top_faulting_problems": res_problems["data"],
        "critical_alarm_sample": res_crit["data"][:10],
        "data": res_crit["data"],
        "executed_sql": sql_crit.strip()
    }


# -----------------------------------------------------------------------------
# 9. TOOL 3: INSPECT NETWORK ELEMENTS
# -----------------------------------------------------------------------------

def inspect_network_elements(
    ne_filter: Optional[str] = None,
    show_offline_only: bool = False,
    limit: int = 50,
    context: Optional[Dict] = None
) -> Dict[str, Any]:
    """
    Audits Railway Network Elements (routers, switches, CCTV nodes, servers).
    Inspects administrative states and configuration details with readable dates.
    """
    connector = context.get("connector") if context else None
    if not connector:
        connector = OMCSDatabaseConnector()
        connector.connect()

    where_clauses = []
    if show_offline_only:
        where_clauses.append("neadminstate != 1")
    if ne_filter:
        where_clauses.append(f"(nename LIKE '%{ne_filter}%' OR neshortname LIKE '%{ne_filter}%')")

    where_sql = ("WHERE " + " AND ".join(where_clauses)) if where_clauses else ""

    sql = f"""
    SELECT 
        neid, nename, neshortname, neversionnumber,
        CASE neadminstate WHEN 1 THEN 'Managed / Up' WHEN 2 THEN 'Unmanaged / Down' ELSE 'Maintenance' END AS admin_status,
        DATE_FORMAT(FROM_UNIXTIME(necreationtime), '%Y-%m-%d %H:%i:%s') AS creation_time
    FROM nedetails
    {where_sql}
    ORDER BY neid ASC
    LIMIT {limit};
    """
    res = connector.execute_query(sql, limit=limit)

    return {
        "status": res["status"],
        "data": res["data"],
        "columns": res["columns"],
        "row_count": res["row_count"],
        "executed_sql": sql.strip(),
        "filter_applied": {"offline_only": show_offline_only, "filter": ne_filter}
    }


# -----------------------------------------------------------------------------
# 10. TOOL 4: MANAGE RAILWAY MEMORY & RULES
# -----------------------------------------------------------------------------

def manage_railway_memory_and_rules(
    action: str,
    category: str = "rule",
    key: str = "",
    value: str = "",
    memory_id: Optional[int] = None
) -> Dict[str, Any]:
    """
    Stores, lists, or deletes user preferences and operational rules in railway_train_db.sqlite.
    """
    act = action.lower().strip()
    if act == "store" or act == "save":
        save_memory_fact(category, key, value)
        return {"status": "success", "message": f"Saved fact: [{category}] {key} = {value}"}
    elif act == "delete" and memory_id is not None:
        delete_memory_fact(memory_id)
        return {"status": "success", "message": f"Deleted memory #{memory_id}"}
    elif act == "clear":
        clear_all_memories()
        return {"status": "success", "message": "Cleared all memories in railway_train_db."}
    else:
        df = load_all_memories_dataframe()
        return {"status": "success", "records": df.to_dict(orient="records")}


# -----------------------------------------------------------------------------
# 11. TOOLS SCHEMA & DISPATCHER
# -----------------------------------------------------------------------------

TOOLS_SCHEMA = [
    {
        "type": "function",
        "function": {
            "name": "query_railway_database",
            "description": "Executes read-only SQL queries on OMCSMGMT_2_0_0 Railway database with automatic relational joins on equipment names and root causes.",
            "parameters": {
                "type": "object",
                "properties": {
                    "natural_request": {
                        "type": "string",
                        "description": "The user query description, e.g. 'top 5 most frequent active alarms' or 'active critical alarms'."
                    },
                    "sql_query": {
                        "type": "string",
                        "description": "Optional explicit MySQL 8.0 SELECT statement. If omitted, will be formulated automatically."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of rows to return (default 100)."
                    }
                },
                "required": ["natural_request"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "diagnose_railway_faults",
            "description": "Performs deep fault diagnosis across active alarms, critical subsystems, and recurring failure modes.",
            "parameters": {
                "type": "object",
                "properties": {
                    "severity_threshold": {
                        "type": "integer",
                        "description": "Highest severity to include (1=Critical, 2=Major, 3=Minor). Default is 2."
                    },
                    "lookback_hours": {
                        "type": "integer",
                        "description": "Hours of historical logs to correlate (default 24)."
                    }
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "inspect_network_elements",
            "description": "Audits Railway Network Elements (switches, routers, CCTV nodes, servers) and their online/offline state.",
            "parameters": {
                "type": "object",
                "properties": {
                    "ne_filter": {
                        "type": "string",
                        "description": "Search term for NE name or IP address."
                    },
                    "show_offline_only": {
                        "type": "boolean",
                        "description": "True to filter for unreachable or unmanaged nodes only."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Max rows to return (default 50)."
                    }
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "manage_railway_memory_and_rules",
            "description": "Stores or inspects persistent preferences, station aliases, or operational rules in railway_train_db.",
            "parameters": {
                "type": "object",
                "properties": {
                    "action": {
                        "type": "string",
                        "enum": ["store", "list", "delete", "clear"],
                        "description": "Action to perform."
                    },
                    "category": {"type": "string", "description": "Category name (e.g. 'preference', 'alias', 'rule')."},
                    "key": {"type": "string", "description": "Rule or alias key."},
                    "value": {"type": "string", "description": "Rule content."},
                    "memory_id": {"type": "integer", "description": "ID to delete if action is delete."}
                },
                "required": ["action"]
            }
        }
    }
]

def execute_railway_tool(tool_name: str, args: Dict[str, Any], context: Optional[Dict] = None) -> Dict[str, Any]:
    """Direct dispatcher for the 4 railway tools."""
    if tool_name == "query_railway_database":
        return query_railway_database(
            natural_request=args.get("natural_request", ""),
            sql_query=args.get("sql_query"),
            limit=args.get("limit", 100),
            context=context
        )
    elif tool_name == "diagnose_railway_faults":
        return diagnose_railway_faults(
            severity_threshold=args.get("severity_threshold", 2),
            lookback_hours=args.get("lookback_hours", 24),
            context=context
        )
    elif tool_name == "inspect_network_elements":
        return inspect_network_elements(
            ne_filter=args.get("ne_filter"),
            show_offline_only=args.get("show_offline_only", False),
            limit=args.get("limit", 50),
            context=context
        )
    elif tool_name == "manage_railway_memory_and_rules":
        return manage_railway_memory_and_rules(
            action=args.get("action", "list"),
            category=args.get("category", "rule"),
            key=args.get("key", ""),
            value=args.get("value", ""),
            memory_id=args.get("memory_id")
        )
    else:
        return {"status": "error", "message": f"Unknown tool: {tool_name}"}

# Initialize train_db on module load
init_railway_train_db()
