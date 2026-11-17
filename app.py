from __future__ import annotations

# -----------------------------------------------------------------------------
# 1. STREAMLIT IMPORT & CONFIG (MUST BE THE VERY FIRST EXECUTED COMMANDS)
# -----------------------------------------------------------------------------
import streamlit as st
import streamlit.components.v1 as components

st.set_page_config(
    page_title="Building Management AI Master Agent",
    page_icon="⚡",
    layout="wide"
)

# -----------------------------------------------------------------------------
# 2. ALL OTHER IMPORTS (STRICTLY AFTER ST.SET_PAGE_CONFIG)
# -----------------------------------------------------------------------------
import json
import os
import re
import sqlite3
import time
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import voice_module as vm  # voice search + live translation (separate file)
import weather_module as wx  # live weather predictions (separate file)

from dotenv import load_dotenv
load_dotenv()

from schema_reader import SchemaReader
from sql_validator import validate_sql, format_sql, ValidationError
from llm_engine import LLMEngine
import bms_tools
from agent_core import BMSAgent

# Import AgentOrchestrator conditionally/safely if present
try:
    from orchestrator import AgentOrchestrator
    MCP_ORCHESTRATOR_AVAILABLE = True
except ImportError:
    MCP_ORCHESTRATOR_AVAILABLE = False

# Import OPNsense Security Engine safely
try:
    import opnsense_dryrun as opn_engine
    OPNSENSE_AVAILABLE = True
except ImportError:
    try:
        import main as opn_engine
        OPNSENSE_AVAILABLE = True
    except ImportError:
        OPNSENSE_AVAILABLE = False

# Import OMCS Silver Validation Agent safely (New Feature)
try:
    from silver_validation_agent import SilverValidationAgent, OMCSSchemaCatalog, DOMAIN_CLUSTERS
    SILVER_AGENT_AVAILABLE = True
except ImportError:
    SILVER_AGENT_AVAILABLE = False

DB_MEMORY_FILE = "db_history.json"
BOOKMARKS_FILE = "categorized_bookmarks.json"
TRAIN_DB_FILE = "train_db.sqlite"

# -----------------------------------------------------------------------------
# 3. CUSTOM STYLING (POSITIONING MIC AT BOTTOM-LEFT OF CHAT INPUT)
# -----------------------------------------------------------------------------
st.markdown(
    """
    <style>
    .stApp { background-color: #0b0e14; color: #e6e6e6; }
    section[data-testid="stSidebar"] { background-color: #10131c; border-right: 1px solid #1f2430; }
    h1, h2, h3, h4, h5, h6, p, span, label, div { color: #e6e6e6; }
    
    .stButton > button {
        background-color: #12151f; border: 1px solid #2a2f3d; border-radius: 8px;
        padding: 0.5rem 0.8rem; text-align: left; color: #e6e6e6; width: 100%;
        transition: all 0.15s ease;
    }
    .stButton > button:hover { border-color: #a855f7; color: #a855f7; }
    
    div[data-baseweb="input"], div[data-baseweb="base-input"], div[data-baseweb="select"] > div {
        background-color: #12151f !important; border: 1px solid #2a2f3d !important;
    }
    input, textarea {
        background-color: #12151f !important; color: #e6e6e6 !important;
        -webkit-text-fill-color: #e6e6e6 !important; caret-color: #e6e6e6 !important;
    }
    
    div[data-testid="stChatMessage"] {
        background-color: #12151f; border: 1px solid #1f2430; border-radius: 12px; padding: 0.8rem 1rem;
        margin-bottom: 0.5rem;
    }
    .connected-badge {
        background-color: #14301f; border: 1px solid #2f6b45; color: #4ade80;
        padding: 0.5rem 0.8rem; border-radius: 8px; font-size: 0.85rem; margin-top: 0.5rem;
    }

    </style>
    """,
    unsafe_allow_html=True,
)
vm.inject_voice_css()

# -----------------------------------------------------------------------------
# 4. DOMAIN DICTIONARY & KNOWLEDGE BASE
# -----------------------------------------------------------------------------
TELEMETRY_DICTIONARY = {
    "virv": {
        "name": "R-Phase Voltage",
        "unit": "V",
        "nominal_range": [210.0, 250.0],
        "description": "Voltage across Red phase to Neutral. Nominal standard is 230V ±10%."
    },
    "viyv": {
        "name": "Y-Phase Voltage",
        "unit": "V",
        "nominal_range": [210.0, 250.0],
        "description": "Voltage across Yellow phase to Neutral. Nominal standard is 230V ±10%."
    },
    "vibv": {
        "name": "B-Phase Voltage",
        "unit": "V",
        "nominal_range": [210.0, 250.0],
        "description": "Voltage across Blue phase to Neutral. Nominal standard is 230V ±10%."
    },
    "vinv": {
        "name": "Neutral Voltage",
        "unit": "V",
        "nominal_range": [0.0, 15.0],
        "description": "Neutral-to-Earth ground potential. High values indicate grounding or load balance issues."
    },
    "viri": {
        "name": "R-Phase Current",
        "unit": "A",
        "nominal_range": [0.0, 100.0],
        "description": "Current drawn on Red phase in Amperes."
    },
    "viyi": {
        "name": "Y-Phase Current",
        "unit": "A",
        "nominal_range": [0.0, 100.0],
        "description": "Current drawn on Yellow phase in Amperes."
    },
    "vibi": {
        "name": "B-Phase Current",
        "unit": "A",
        "nominal_range": [0.0, 100.0],
        "description": "Current drawn on Blue phase in Amperes."
    },
    "vicurrentimbalance": {
        "name": "Current Imbalance",
        "unit": "%",
        "max_threshold": 10.0,
        "description": "Current imbalance percentage across phases. Above 10% can damage motors and transformers."
    },
    "vibattery": {
        "name": "Sensor Battery Voltage",
        "unit": "V",
        "nominal_range": [3.3, 4.2],
        "description": "Battery voltage of telemetry IoT sensor module. Below 3.4V requires replacement or charging."
    },
    "vitemp": {
        "name": "Sensor / Enclosure Temperature",
        "unit": "°C",
        "max_threshold": 60.0,
        "description": "Internal operating temperature of the electrical panel monitor. >60°C triggers thermal alert."
    },
    "vienergy": {
        "name": "Cumulative Energy",
        "unit": "kWh",
        "nominal_range": [0.0, 999999.0],
        "description": "Total active electric energy consumed over time."
    },
    "vidatetime": {
        "name": "Telemetry Timestamp",
        "unit": "datetime",
        "description": "Raw Epoch seconds. Convert using FROM_UNIXTIME(vidatetime, '%H:%i:%s') for readable time."
    },
    "vicreatedtime": {
        "name": "Created Date",
        "unit": "string",
        "description": "Formatted record date (MM/DD/YYYY)."
    }
}

FEW_SHOT_EXAMPLES = [
    {
        "question": "Show me phase voltages from the last 24 hours",
        "sql": "SELECT vicreatedtime AS date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS time, virv, viyv, vibv FROM vinereadings WHERE vidatetime >= UNIX_TIMESTAMP(NOW() - INTERVAL 24 HOUR) ORDER BY vidatetime ASC LIMIT 500;",
        "explanation": "Retrieves voltage trends with human-readable date and time for the past 24 hours."
    },
    {
        "question": "Are there any voltage sags or spikes outside 210V to 250V?",
        "sql": "SELECT vicreatedtime AS date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS time, virv, viyv, vibv FROM vinereadings WHERE virv < 210 OR virv > 250 OR viyv < 210 OR viyv > 250 OR vibv < 210 OR vibv > 250 ORDER BY vidatetime DESC LIMIT 100;",
        "explanation": "Finds readings where phase voltages breach safe electrical ranges with formatted dates."
    },
    {
        "question": "Show readings where current imbalance exceeds 10%",
        "sql": "SELECT vicreatedtime AS date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS time, vicurrentimbalance, viri, viyi, vibi FROM vinereadings WHERE vicurrentimbalance > 10 ORDER BY vidatetime DESC LIMIT 100;",
        "explanation": "Filters severe phase current imbalances with readable dates and times."
    },
    {
        "question": "What is the peak temperature and highest current today?",
        "sql": "SELECT MAX(vitemp) AS max_temperature_c, GREATEST(MAX(viri), MAX(viyi), MAX(vibi)) AS peak_phase_current_a FROM vinereadings WHERE STR_TO_DATE(vicreatedtime, '%m/%d/%Y') = CURDATE();",
        "explanation": "Calculates peak daily thermal and electrical demand metrics using vicreatedtime."
    },
    {
        "question": "What are the latest 10 readings from the system?",
        "sql": "SELECT vicreatedtime AS reading_date, DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time, virv, viyv, vibv, viri, viyi, vibi, vitemp, vibattery FROM vinereadings ORDER BY vidatetime DESC LIMIT 10;",
        "explanation": "Pulls recent telemetry snapshots displaying date from vicreatedtime and converted readable time."
    }
]

SYSTEM_RULES = [
    "ONLY use column names that strictly exist in the schema.",
    "ALWAYS format readable output columns using: `vicreatedtime AS reading_date` AND `DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time`.",
    "NEVER display raw `1790644222` numbers to the user without converting via `FROM_UNIXTIME(vidatetime)`.",
    "Order by vidatetime DESC for latest status, or ASC for time-series charts.",
    "Never generate DDL/DML statements (no DROP, DELETE, INSERT, UPDATE, ALTER).",
    "Always enforce a LIMIT clause (default 500) to protect database performance.",
    "For phase voltages use virv, viyv, vibv. For phase currents use viri, viyi, vibi.",
    "Check vicurrentimbalance (>10%) and vitemp (>60°C) for building hazard alerts."
]

def export_knowledge_base_json(schema_dict: dict | None = None, db_name: str = "") -> str:
    default_db = os.getenv("DB_NAME", "")
    package = {
        "metadata": {
            "title": "Building Electrical Telemetry AI Knowledge Base",
            "database_name": db_name or default_db,
            "version": "2.0.0",
            "exported_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "target_system": "Universal AI Agent / LLM Text-to-SQL Framework"
        },
        "telemetry_dictionary": TELEMETRY_DICTIONARY,
        "few_shot_queries": FEW_SHOT_EXAMPLES,
        "system_rules": SYSTEM_RULES,
        "database_schema": schema_dict or {}
    }
    return json.dumps(package, indent=2)

def export_knowledge_base_markdown(schema_text: str = "", db_name: str = "") -> str:
    active_db = db_name or os.getenv("DB_NAME", "")
    lines = [
        f"# ⚡ Building Electrical Telemetry Knowledge Base ({active_db})",
        f"*Exported: {time.strftime('%Y-%m-%d %H:%M:%S')}*\n",
        "## 1. System Overview",
        "This knowledge base defines the data schema, telemetry metrics, and business rules for an industrial Building Management System (BMS) monitoring multi-phase electrical power, voltages, currents, thermal parameters, and sensor health.\n",
        "## 2. Telemetry Dictionary & Alert Thresholds\n",
        "| Column | Metric Name | Unit | Nominal / Safe Range | Description |",
        "|---|---|---|---|---|"
    ]
    
    for col, meta in TELEMETRY_DICTIONARY.items():
        nom = "N/A"
        if "nominal_range" in meta:
            nom = f"{meta['nominal_range'][0]} - {meta['nominal_range'][1]} {meta.get('unit', '')}"
        elif "max_threshold" in meta:
            nom = f"Max {meta['max_threshold']} {meta.get('unit', '')}"
        lines.append(f"| `{col}` | {meta['name']} | {meta.get('unit', '')} | {nom} | {meta['description']} |")
        
    lines.append("\n## 3. Recommended Golden SQL Queries (Few-Shot Examples)\n")
    for i, ex in enumerate(FEW_SHOT_EXAMPLES, 1):
        lines.append(f"### Example {i}: {ex['question']}")
        lines.append(f"```sql\n{ex['sql']}\n```")
        lines.append(f"*{ex['explanation']}*\n")
        
    lines.append("## 4. Operational & Safety Rules")
    for r in SYSTEM_RULES:
        lines.append(f"- {r}")
        
    if schema_text:
        lines.append("\n## 5. Active Database Schema")
        lines.append(f"```sql\n{schema_text}\n```")
        
    return "\n".join(lines)

# -----------------------------------------------------------------------------
# 5. TRAIN_DB PERSISTENT MEMORY ENGINE (WITH DELETE SUPPORT)
# -----------------------------------------------------------------------------
def init_train_db():
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

def load_db_memory() -> dict:
    if os.path.exists(DB_MEMORY_FILE):
        try:
            with open(DB_MEMORY_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_db_memory(memory: dict):
    with open(DB_MEMORY_FILE, "w") as f:
        json.dump(memory, f, indent=4)

def record_db_usage(host, port, user, password, database):
    memory = load_db_memory()
    key = f"{host}:{port}/{database}"
    memory[key] = {
        "host": host, "port": port, "user": user, "password": password,
        "database": database, "count": memory.get(key, {}).get("count", 0) + 1
    }
    save_db_memory(memory)

def load_bookmarks() -> dict[str, list[str]]:
    if os.path.exists(BOOKMARKS_FILE):
        try:
            with open(BOOKMARKS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {"Energy Trends": [], "Device Audits": [], "General": []}
    return {"Energy Trends": [], "Device Audits": [], "General": []}

def save_bookmarks(bookmarks: dict[str, list[str]]):
    with open(BOOKMARKS_FILE, "w") as f:
        json.dump(bookmarks, f, indent=4)

if "messages" not in st.session_state:
    st.session_state["messages"] = []

if "bookmarks" not in st.session_state:
    st.session_state["bookmarks"] = load_bookmarks()

if "sql_execution_logs" not in st.session_state:
    st.session_state["sql_execution_logs"] = []

if "pending_query" not in st.session_state:
    st.session_state["pending_query"] = None

if "silver_dataset" not in st.session_state:
    if os.path.exists("omcs_silver_validation_dataset.json"):
        try:
            with open("omcs_silver_validation_dataset.json", "r", encoding="utf-8") as f:
                st.session_state["silver_dataset"] = json.load(f)
        except Exception:
            st.session_state["silver_dataset"] = []
    else:
        st.session_state["silver_dataset"] = []

@st.cache_resource(show_spinner="Initializing AI Engine...")
def get_llm():
    engine = LLMEngine()
    engine.load()
    return engine

def connect_to_db(host, port, user, password, database):
    reader = SchemaReader(host, port, user, password, database)
    reader.connect()
    st.session_state["reader"] = reader
    st.session_state["schema_text"] = reader.build_schema_text()
    st.session_state["tables"] = reader.get_tables()
    st.session_state["db_name"] = database
    st.session_state["schema_dict"] = reader.get_schema_dict()
    st.session_state["db_creds"] = {
        "host": host, "port": port, "user": user, "password": password, "database": database
    }
    record_db_usage(host, port, user, password, database)

init_train_db()

# -----------------------------------------------------------------------------
# 6. MASTER PROMPT INSTRUCTIONS
# -----------------------------------------------------------------------------
BUILDING_MANAGEMENT_MASTER_PROMPT = f"""
[MASTER BUILDING MANAGEMENT & TELEMETRY RULES]:
1. DEVICE IDENTIFICATION:
   - Device sensors use `vineid` (in `vinereadings`) or `subSystemId` / `deviceid` in equipment details.
   - To show data for specific devices, group or filter using `vineid` or `subSystemId`.

2. READABLE DATE AND TIME FORMATTING RULES (CRITICAL):
   - Take the DATE directly from `vicreatedtime` (e.g. `vicreatedtime AS reading_date`).
   - Convert the TIME from `vidatetime` using: `DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time`.
   - NEVER output raw `1790644222` numbers to the user without formatting them.
   - ALWAYS `ORDER BY vidatetime DESC` when asked for recent/latest readings, or `ORDER BY vidatetime ASC` for time-series charts.

3. HOURLY ENERGY METRICS:
   - If querying `HourwiseEnergyUsage` or `HourwiseEnergyUsageTapo110`: Select `date`, `hour`, `energy`, `subSystemId` ORDER BY `date` ASC, `hour` ASC.
   - If querying raw `vinereadings`: Select `vineid`, `vicreatedtime AS reading_date`, `DATE_FORMAT(FROM_UNIXTIME(vidatetime), '%h:%i:%s %p') AS reading_time`, `vienergy`, `virv`, `viyv`, `vibv`, `viri`, `viyi`, `vibi`.

4. EXPLANATION & EDUCATIONAL MODE:
   - If user asks to "explain", "teach", or "describe" fields or data (e.g. `viri`, `virv`), explain technical definitions, units, and operational building impacts.

5. SYSTEM RULES:
{chr(10).join(f'   - {r}' for r in SYSTEM_RULES)}
"""

# -----------------------------------------------------------------------------
# 7. MASTER PLOTLY GRAPH ENGINE
# -----------------------------------------------------------------------------
GRAFANA_PALETTE = ["#73bf69", "#f2c96d", "#f2495c", "#5794f2", "#b877d9", "#ff780a", "#e0b400"]

def build_master_chart(question: str, df: pd.DataFrame):
    if df is None or df.empty:
        return None

    plot_df = df.copy()

    ignore_ids = {"vireadingid", "id", "recordid", "vineid", "subsystemid", "deviceid", "vidatetime"}
    for col in plot_df.columns:
        if col.lower() not in ignore_ids:
            try:
                plot_df[col] = pd.to_numeric(plot_df[col])
            except Exception:
                pass

    device_col = next((c for c in plot_df.columns if c.lower() in ["vineid", "subsystemid", "deviceid"]), None)
    time_col = next((c for c in plot_df.columns if any(k in c.lower() for k in ["time", "date", "reading_time", "reading_date", "createdtime", "local_time"])), None)
    hour_col = next((c for c in plot_df.columns if c.lower() == "hour"), None)

    numeric_cols = [c for c in plot_df.select_dtypes("number").columns if c.lower() not in ignore_ids and c.lower() != "hour"]

    if not numeric_cols:
        return None

    x_axis = time_col if time_col else hour_col
    if x_axis:
        plot_df = plot_df.sort_values(by=x_axis)
        fig = go.Figure()
        target_metric = numeric_cols[0]

        if device_col:
            unique_devices = plot_df[device_col].unique()[:10]
            for idx, dev in enumerate(unique_devices):
                dev_df = plot_df[plot_df[device_col] == dev]
                color = GRAFANA_PALETTE[idx % len(GRAFANA_PALETTE)]
                fig.add_trace(go.Scatter(
                    x=dev_df[x_axis],
                    y=dev_df[target_metric],
                    mode="lines+markers",
                    name=f"Device {dev}",
                    line=dict(color=color, width=2),
                    marker=dict(size=4)
                ))
            chart_title = f"📈 Device Trend ({target_metric})"
        else:
            for idx, metric in enumerate(numeric_cols[:4]):
                color = GRAFANA_PALETTE[idx % len(GRAFANA_PALETTE)]
                fig.add_trace(go.Scatter(
                    x=plot_df[x_axis],
                    y=plot_df[metric],
                    mode="lines+markers",
                    name=metric,
                    line=dict(color=color, width=2),
                    marker=dict(size=3)
                ))
            chart_title = f"📈 Telemetry Analysis ({', '.join(numeric_cols[:3])})"

        fig.update_layout(
            template="plotly_dark",
            paper_bgcolor="#111217",
            plot_bgcolor="#181b1f",
            font=dict(family="sans-serif", color="#d8d9da", size=11),
            title=dict(text=f"<b>{chart_title}</b>", font=dict(size=13, color="#f4f5f5"), x=0.01),
            margin=dict(l=30, r=20, t=35, b=30),
            hovermode="x unified",
            legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1)
        )
        return fig

    fig = px.bar(
        plot_df, 
        x=device_col if device_col else plot_df.columns[0], 
        y=numeric_cols[0],
        color_discrete_sequence=["#5794f2"]
    )
    fig.update_layout(
        template="plotly_dark",
        paper_bgcolor="#111217",
        plot_bgcolor="#181b1f",
        title=f"<b>{numeric_cols[0]} Breakdown</b>"
    )
    return fig

# -----------------------------------------------------------------------------
# 8. SIDEBAR CONTROLS, LOGS & EXPORTS
# -----------------------------------------------------------------------------
with st.sidebar:
    st.markdown("### 🔌 Database Connection")
    
    memory = load_db_memory()
    if memory:
        st.markdown("**Frequent Databases:**")
        for key, info in memory.items():
            if st.button(f"🗄️ {info['database']}", key=f"nav_{key}", use_container_width=True):
                try:
                    connect_to_db(info["host"], info["port"], info["user"], info["password"], info["database"])
                    st.success(f"Connected to {info['database']}")
                    st.rerun()
                except Exception as e:
                    st.error(f"Error: {e}")
        st.divider()

    with st.expander("🔌 Connect Manual DB", expanded="reader" not in st.session_state):
        host = st.text_input("Host", value=os.getenv("DB_HOST", ""))
        port = st.number_input("Port", value=int(os.getenv("DB_PORT", 3306)), step=1)
        user = st.text_input("Username", value=os.getenv("DB_USER", ""))
        password = st.text_input("Password", value=os.getenv("DB_PASSWORD", ""), type="password")
        database = st.text_input("Database name", value=os.getenv("DB_NAME", ""))
        
        if st.button("Connect DB", type="primary", use_container_width=True):
            try:
                connect_to_db(host, port, user, password, database)
                st.rerun()
            except Exception as e:
                st.error(f"Connection failed: {e}")

    if "reader" in st.session_state:
        st.markdown(f'<div class="connected-badge">✅ Active: <b>{st.session_state["db_name"]}</b></div>', unsafe_allow_html=True)
        st.divider()
        
        vm.render_voice_settings()
        st.divider()

        st.markdown("### 🧠 AI Knowledge Base")
        kb_json = export_knowledge_base_json(
            schema_dict=st.session_state.get("schema_dict", {}),
            db_name=st.session_state.get("db_name", "")
        )
        st.download_button(
            label="📦 Export Schema KB (.json)",
            data=kb_json.encode("utf-8"),
            file_name=f"{st.session_state.get('db_name', 'database')}_knowledge_base.json",
            mime="application/json",
            key="dl_kb_json",
            use_container_width=True,
        )
        
        kb_md = export_knowledge_base_markdown(
            schema_text=st.session_state.get("schema_text", ""),
            db_name=st.session_state.get("db_name", "")
        )
        st.download_button(
            label="📄 Export KB Documentation (.md)",
            data=kb_md.encode("utf-8"),
            file_name=f"{st.session_state.get('db_name', 'database')}_knowledge_base.md",
            mime="text/markdown",
            key="dl_kb_md",
            use_container_width=True,
        )
        st.divider()

    wx.render_settings()
    st.divider()

    st.markdown("### 💾 Persistent Train DB Memory")
    mem_df = load_all_memories_dataframe()
    if not mem_df.empty:
        for idx, row in mem_df.iterrows():
            col1, col2 = st.columns([0.85, 0.15])
            with col1:
                st.caption(f"📌 **[{row['category'].upper()}]** {row['memory_value']}")
            with col2:
                if st.button("🗑️", key=f"del_mem_{row['id']}", help="Delete this rule from train_db"):
                    delete_memory_fact(int(row["id"]))
                    st.toast("🗑️ Fact deleted from train_db!")
                    st.rerun()

        col_clr1, col_clr2 = st.columns([0.5, 0.5])
        with col_clr1:
            mem_json = mem_df.to_json(orient="records", indent=2)
            st.download_button(
                label="📦 Export (.json)",
                data=mem_json.encode("utf-8"),
                file_name="train_db_memory.json",
                mime="application/json",
                key="dl_train_db_json",
                use_container_width=True
            )
        with col_clr2:
            if st.button("💥 Clear All", key="clear_all_train_db", use_container_width=True):
                clear_all_memories()
                st.toast("Cleared all facts from train_db!")
                st.rerun()
    else:
        st.caption("No learned rules/aliases stored in train_db yet.")
    st.divider()

    st.markdown("### 🔍 Live Executed SQL Commands")
    if st.session_state["sql_execution_logs"]:
        for log in reversed(st.session_state["sql_execution_logs"][-5:]):
            st.caption(f"⏱️ **[{log['timestamp']}]** (`{log['time_taken']:.2f}s`)")
            st.code(log["sql"], language="sql")
    else:
        st.caption("No SQL commands executed yet.")
    st.divider()

    st.markdown("### 🔖 Categorized Bookmarks")
    with st.popover("➕ New Folder", use_container_width=True):
        new_folder = st.text_input("Folder Name")
        if st.button("Create Folder") and new_folder:
            if new_folder not in st.session_state["bookmarks"]:
                st.session_state["bookmarks"][new_folder] = []
                save_bookmarks(st.session_state["bookmarks"])
                st.rerun()

    bookmarks = st.session_state["bookmarks"]
    for folder_name, folder_prompts in list(bookmarks.items()):
        with st.expander(f"📁 {folder_name} ({len(folder_prompts)})"):
            if not folder_prompts:
                st.caption("Empty folder")
            for p_idx, prompt in enumerate(folder_prompts):
                col1, col2 = st.columns([0.8, 0.2])
                with col1:
                    if st.button(f"📌 {prompt[:18]}...", key=f"run_bm_{folder_name}_{p_idx}", help=prompt, use_container_width=True):
                        st.session_state["pending_query"] = prompt
                        st.rerun()
                with col2:
                    if st.button("❌", key=f"del_bm_{folder_name}_{p_idx}"):
                        st.session_state["bookmarks"][folder_name].pop(p_idx)
                        save_bookmarks(st.session_state["bookmarks"])
                        st.rerun()

    st.divider()
    if st.button("🗑️ Clear Chat History", use_container_width=True):
        st.session_state["messages"] = []
        st.session_state["sql_execution_logs"] = []
        st.rerun()

# -----------------------------------------------------------------------------
# 9. EXECUTION PIPELINE WITH TRAIN_DB ENGINE & DIRECT MAIN.PY / OPNSENSE ROUTING
# -----------------------------------------------------------------------------
def _extract_sql(raw: str) -> str:
    """Strip markdown fences / 'sql' labels so validate_sql gets a clean statement."""
    if not raw:
        return ""
    text = raw.strip()
    if "```" in text:
        parts = text.split("```")
        if len(parts) >= 2:
            text = parts[1]
            if text.lower().startswith("sql"):
                text = text[3:]
    return text.strip()

def run_pipeline(question: str):
    clean_q = question.strip().lower()

    # 1. Immediate greetings handler
    greetings = {"hi", "hello", "hey", "hola", "good morning", "good evening"}
    if clean_q in greetings:
        st.session_state["messages"].append({"role": "user", "content": question})
        reply = f"Hello! Ready to analyze your building telemetry or inspect firewall security. Connected to **{st.session_state.get('db_name', 'database')}**."
        st.session_state["messages"].append({"role": "assistant", "content": reply})
        st.rerun()
        return

    # 2. Immediate memory statement handler
    memory_triggers = ["important", "core for", "personal use", "remember that", "note that", "note if", "vital information", "save alias"]
    is_memory_only = any(phrase in clean_q for phrase in memory_triggers) and not any(
        cmd in clean_q for cmd in ["show", "get", "plot", "select", "find", "what", "how", "list", "fetch"]
    )
    if is_memory_only:
        save_memory_fact("user_preference", "Alias / Preference Rule", question)
        st.session_state["messages"].append({"role": "user", "content": question})
        reply = f"Got it! I have stored this rule in **train_db**:\n> *\"{question}\"*\n\nI will apply this mapping to your upcoming queries."
        st.session_state["messages"].append({"role": "assistant", "content": reply})
        st.rerun()
        return

    # 3. Autonomous Tool-Calling Agent Execution
    st.session_state["messages"].append({"role": "user", "content": question})

    context = {
        "reader": st.session_state.get("reader"),
        "schema_text": st.session_state.get("schema_text", ""),
        "tables": st.session_state.get("tables", []),
        "db_name": st.session_state.get("db_name", ""),
        "history": st.session_state.get("messages", [])
    }

    with st.spinner("🤖 Analyzing building telemetry and evaluating security policies..."):
        try:
            llm = get_llm()
            agent_res = llm.run_agent(
                question=question,
                history=st.session_state["messages"],
                context=context
            )
        except Exception as e:
            st.session_state["messages"].append({
                "role": "assistant",
                "content": f"⚠️ An error occurred while executing the autonomous agent: {e}",
                "question": question
            })
            st.rerun()
            return

    # Extract any dataframes produced by tools
    df = agent_res.dataframes[0] if agent_res.dataframes else pd.DataFrame()
    pretty_sql = agent_res.raw_sql

    if pretty_sql:
        st.session_state["sql_execution_logs"].append({
            "timestamp": time.strftime("%H:%M:%S"),
            "sql": pretty_sql,
            "time_taken": 0.05
        })

    tool_names = [tc["tool"] for tc in agent_res.tool_calls] if agent_res.tool_calls else []

    st.session_state["messages"].append({
        "role": "assistant",
        "content": agent_res.answer,
        "sql": pretty_sql or None,
        "df": df if not df.empty else None,
        "question": question,
        "tool_calls": tool_names
    })
    st.rerun()

# -----------------------------------------------------------------------------
# 10. MAIN PAGE INTERFACE & DASHBOARD TABS
# -----------------------------------------------------------------------------
st.markdown("# ⚡ Building Management AI Master Agent")

tab1, tab2, tab3 = st.tabs([
    "💬 BMS AI Chat & Telemetry", 
    "🛡️ OPNsense Security Engine", 
    "🎯 OMCS Silver Benchmark & Question Generator"
])

with tab1:
    if "reader" not in st.session_state:
        st.info("👈 Please connect to your Building Management Database in the sidebar to begin.")

    # Chat history rendering area
    chat_container = st.container()
    with chat_container:
        for idx, msg in enumerate(st.session_state["messages"]):
            with st.chat_message(msg["role"]):
                st.markdown(msg["content"])
                
                if "df" in msg and msg["df"] is not None and not msg["df"].empty:
                    df = msg["df"]
                    st.dataframe(df, use_container_width=True)
                    
                    q_lower = msg.get("question", "").lower()
                    plot_keywords = ["plot", "trend", "graph", "chart", "draw", "visualize", "diagram"]
                    if any(k in q_lower for k in plot_keywords):
                        chart = build_master_chart(msg.get("question", ""), df)
                        if chart is not None:
                            st.plotly_chart(chart, use_container_width=True, key=f"hist_chart_{idx}")

                    json_bytes = df.to_json(orient="records", date_format="iso", indent=2).encode("utf-8")
                    st.download_button("📋 Export Query Data (.json)", json_bytes, "query_data.json", "application/json", key=f"dl_json_{idx}")

                    if msg.get("question"):
                        q_text = msg["question"]
                        with st.popover("🔖 Bookmark Prompt"):
                            target_folder = st.selectbox("Folder", list(st.session_state["bookmarks"].keys()), key=f"fold_sel_{idx}")
                            if st.button("Save Bookmark", key=f"save_bm_btn_{idx}"):
                                if q_text not in st.session_state["bookmarks"][target_folder]:
                                    st.session_state["bookmarks"][target_folder].append(q_text)
                                    save_bookmarks(st.session_state["bookmarks"])
                                    st.toast(f"Saved to {target_folder}!")
                                    st.rerun()

with tab2:
    st.markdown("### 🛡️ OPNsense Firewall & Port Security Command Center")
    st.caption("Integrated OPNsense dry-run security engine, risky port checks, and firewall inspection generator.")

    if OPNSENSE_AVAILABLE:
        st.info(f"🔒 **Target Appliance:** `{opn_engine.HOST}` | **Execution Mode:** `DRY-RUN (Safe Simulation)` | **API Status:** `Credentials Loaded`")
    else:
        st.warning("⚠️ OPNsense module not detected in working directory.")

    col_sec1, col_sec2 = st.columns([0.55, 0.45])

    with col_sec1:
        st.markdown("#### 🔍 Custom Firewall & Port Inspection")
        sec_query = st.text_input(
            "Enter a security command or port check",
            placeholder="e.g. 'is port 69 safe', 'check port 3306', 'block port 3389', 'show firewall rules', 'query states'",
            key="sec_tab_input"
        )
        if st.button("🚀 Run Security Inspection", type="primary", use_container_width=True):
            if OPNSENSE_AVAILABLE and sec_query:
                output = opn_engine.handle(sec_query)
                st.code(output, language="text")
            elif not OPNSENSE_AVAILABLE:
                st.error("OPNsense module (opnsense_dryrun.py) not available.")
            else:
                st.warning("Please enter a query or select a quick action.")

    with col_sec2:
        st.markdown("#### ⚡ Quick Port Safety Checks")
        col_p1, col_p2 = st.columns(2)
        with col_p1:
            if st.button("🔍 Port 69 (TFTP UDP)", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("is port 69 safe"), language="text")
            if st.button("🔍 Port 3306 (MySQL DB)", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("is port 3306 safe"), language="text")
            if st.button("🔍 Port 502 (Modbus BMS)", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("is port 502 safe"), language="text")

        with col_p2:
            if st.button("🔍 Port 47808 (BACnet)", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("is port 47808 safe"), language="text")
            if st.button("🔍 Port 3389 (RDP)", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("is port 3389 safe"), language="text")
            if st.button("🚫 Block Port 3389", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.propose_block("block port 3389"), language="text")

        st.markdown("#### 🛠️ Firewall Command Audits")
        col_c1, col_c2 = st.columns(2)
        with col_c1:
            if st.button("📜 Firewall Rules", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("show firewall rules"), language="text")
            if st.button("📊 Query pf States", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("query active states"), language="text")
        with col_c2:
            if st.button("⚙️ Listening Daemons", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.handle("listening socket services"), language="text")
            if st.button("📋 Full Risk Matrix", use_container_width=True):
                if OPNSENSE_AVAILABLE:
                    st.code(opn_engine.vulnerable_ports_text(), language="text")

with tab3:
    st.markdown("### 🎯 Railway OMCS Database (`OMCSMGMT_2_0_0`) — Autonomous Silver Validation Benchmark")
    st.caption("Autonomous Schema Analysis, Multi-Tier Question & SQL Framing, and Ground-Truth Golden Set Generation for LLM Evaluation.")

    if not SILVER_AGENT_AVAILABLE:
        st.warning("⚠️ Silver Validation Agent module not found in working directory.")
    else:
        catalog = OMCSSchemaCatalog()
        agent = SilverValidationAgent(catalog)
        summary = agent.get_domain_summary()

        # Summary KPIs
        m1, m2, m3, m4 = st.columns(4)
        m1.metric("📋 Schema Tables", summary["total_tables"])
        m2.metric("🏷️ Domain Clusters", len(DOMAIN_CLUSTERS))
        m3.metric("🎯 Complexity Tiers", len(COMPLEXITY_TIERS))
        m4.metric("📁 Silver QA Pairs", len(st.session_state.get("silver_dataset", [])))

        # Schema & Domain Architecture Expander
        with st.expander("🔍 Explore OMCS 173-Table Schema & Domain Architecture", expanded=False):
            st.markdown("The **OMCSMGMT_2_0_0** database manages operational, maintenance, alarm, and telecommunication infrastructure across railway stations and network elements.")
            
            d_cols = st.columns(2)
            domain_items = list(DOMAIN_CLUSTERS.items())
            for idx, (dom_name, tbl_list) in enumerate(domain_items):
                target_col = d_cols[idx % 2]
                with target_col:
                    st.markdown(f"**{dom_name}** ({len(tbl_list)} Tables)")
                    if dom_name == "Safety & Guardrail Boundaries":
                        st.caption("Adversarial DDL injections (DROP/DELETE), live physical switching commands, non-existent columns.")
                    else:
                        tbl_tags = " • ".join([f"`{t}`" for t in tbl_list])
                        st.caption(tbl_tags)

        # Generator Dashboard
        st.markdown("#### ⚡ Autonomous Question & Answer Framing Engine")
        col_ctl1, col_ctl2, col_ctl3 = st.columns([0.45, 0.25, 0.3])
        
        with col_ctl1:
            sel_domain = st.selectbox(
                "Target Domain Cluster",
                ["All Domains"] + list(DOMAIN_CLUSTERS.keys()),
                key="sel_silver_dom"
            )
        with col_ctl2:
            num_q = st.selectbox(
                "Questions Count",
                [5, 10, 16, 25],
                index=2,
                key="sel_silver_count"
            )
        with col_ctl3:
            gen_mode = st.selectbox(
                "Engine Mode",
                ["High-Speed Autonomous Engine", "Dynamic LLM Exploration (Qwen)"],
                key="sel_silver_mode"
            )

        if st.button("🚀 Generate Silver Question & Answer Validation Set", type="primary", use_container_width=True):
            with st.spinner("🧠 Analyzing OMCS schema head-to-toe and framing operational question-answer pairs..."):
                use_llm = "LLM" in gen_mode
                dom_target = "All" if sel_domain == "All Domains" else sel_domain
                records = agent.generate_questions_for_domain(dom_target, count=num_q, use_llm=use_llm)
                st.session_state["silver_dataset"] = records
                agent.generated_records = records
                agent.export_dataset()
                st.toast(f"✅ Generated {len(records)} Silver Validation QA Pairs!")
                st.rerun()

        # Display Silver Dataset
        records = st.session_state.get("silver_dataset", [])
        if records:
            st.markdown(f"#### 📋 Current Silver Benchmark Dataset ({len(records)} Question-Answer Pairs)")
            
            f1, f2 = st.columns([0.65, 0.35])
            with f1:
                search_text = st.text_input("🔍 Search question or SQL query", placeholder="Filter by keyword (e.g. 'alarm', 'nedetails', 'critical')...", key="silver_search").lower()
            with f2:
                tier_filter = st.selectbox("Filter Complexity", ["All Tiers", "Simple", "Moderate", "Complex", "Highly Complex", "Guardrail - Safety"], key="tier_filter")

            filtered_records = []
            for r in records:
                tier_match = (tier_filter == "All Tiers") or (tier_filter in r.get("complexity_tier", ""))
                search_match = (
                    search_text in r.get("question", "").lower() or
                    search_text in r.get("ground_truth_mysql", "").lower() or
                    search_text in r.get("domain", "").lower()
                )
                if tier_match and (not search_text or search_match):
                    filtered_records.append(r)

            st.caption(f"Showing **{len(filtered_records)}** of **{len(records)}** records:")

            for rec in filtered_records:
                tier = rec.get("complexity_tier", "Standard")
                is_guardrail = "Guardrail" in tier or rec.get("validation_status") == "EXPECTED_REFUSAL"
                status_badge = "🛑 EXPECTED_REFUSAL" if is_guardrail else "✅ SILVER_VALIDATED"
                badge_color = "red" if is_guardrail else "green"

                with st.container():
                    st.markdown(
                        f"**`[{rec.get('test_id', 'N/A')}]`** | **Domain:** `{rec.get('domain', 'OMCS')}` | **Tier:** `{tier}` | **Persona:** *{rec.get('user_persona', 'Operator')}*"
                    )
                    st.markdown(f"##### ❓ Question:\n> **{rec.get('question')}**")
                    
                    with st.expander("🛠️ Ground-Truth MySQL 8.0 Query", expanded=not is_guardrail):
                        st.code(rec.get("ground_truth_mysql", ""), language="sql" if not is_guardrail else "text")

                    st.markdown(f"##### 💡 Expected Model Answer & Operational Insight:\n{rec.get('expected_answer')}")
                    st.markdown(f":{badge_color}[**Status:** {status_badge}]")
                    st.divider()

            # Export dataset buttons
            c_exp1, c_exp2 = st.columns(2)
            with c_exp1:
                json_bytes = json.dumps(records, indent=2, ensure_ascii=False).encode("utf-8")
                st.download_button("📥 Download Silver Benchmark (.json)", json_bytes, "omcs_silver_validation_dataset.json", "application/json", use_container_width=True)
            with c_exp2:
                df_export = pd.DataFrame(records)
                csv_bytes = df_export.to_csv(index=False).encode("utf-8")
                st.download_button("📥 Download Silver Benchmark (.csv)", csv_bytes, "omcs_silver_validation_dataset.csv", "text/csv", use_container_width=True)
        else:
            st.info("💡 Click **'🚀 Generate Silver Question & Answer Validation Set'** above to autonomously frame operational questions from the OMCS schema.")

# -----------------------------------------------------------------------------
# 11. MIC BUTTON & INPUT HANDLING
# -----------------------------------------------------------------------------

# Handle pending bookmark query execution
if st.session_state["pending_query"]:
    q = st.session_state["pending_query"]
    st.session_state["pending_query"] = None
    run_pipeline(q)

# Voice search + live translation lives in voice_module.py
vm.render_voice_input()

# Native Chat Input
question = st.chat_input("Ask a question about building telemetry or firewall security...")
if question:
    if wx.should_handle(question):
        wx.answer_in_chat(question)    # live weather predictions (research analyst mode)
    else:
        run_pipeline(question)