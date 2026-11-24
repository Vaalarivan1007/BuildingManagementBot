from __future__ import annotations

# -----------------------------------------------------------------------------
# 1. STREAMLIT IMPORT & CONFIG (MUST BE FIRST)
# -----------------------------------------------------------------------------
import streamlit as st

st.set_page_config(
    page_title="Railway Network AI Master Agent",
    page_icon="🚆",
    layout="wide"
)

# -----------------------------------------------------------------------------
# 2. ALL OTHER IMPORTS
# -----------------------------------------------------------------------------
import json
import os
import re
import sqlite3
import time
from typing import Any, Dict, List, Optional
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

import railway_tools
from railway_tools import (
    OMCSDatabaseConnector,
    DEFAULT_DB_CONFIG,
    SEVERITY_MAPPING,
    load_bookmarks,
    save_bookmarks,
    load_all_memories_dataframe,
    delete_memory_fact,
    clear_all_memories,
    save_memory_fact,
    format_dataframe_human_friendly
)
from railway_agent_core import RailwayAgent, AgentExecutionResult

# -----------------------------------------------------------------------------
# 3. CUSTOM STYLING (BMS MASTER THEME - POLISHED DARK MODE)
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
    .stButton > button:hover { border-color: #38bdf8; color: #38bdf8; }
    
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
        padding: 0.5rem 0.8rem; border-radius: 8px; font-size: 0.85rem; margin-top: 0.3rem; margin-bottom: 0.8rem;
    }
    .demo-chip-btn > button {
        background-color: #171b26; border: 1px solid #38bdf8; border-radius: 20px;
        color: #e2e8f0; font-size: 0.85rem; padding: 0.35rem 0.75rem; text-align: center;
    }
    .demo-chip-btn > button:hover {
        background-color: #1e293b; color: #38bdf8; border-color: #7dd3fc;
    }
    </style>
    """,
    unsafe_allow_html=True,
)

# -----------------------------------------------------------------------------
# 4. INITIALIZE SESSION STATE & SINGLETONS
# -----------------------------------------------------------------------------
if "messages" not in st.session_state:
    st.session_state["messages"] = []

if "bookmarks" not in st.session_state:
    st.session_state["bookmarks"] = load_bookmarks()

if "sql_execution_logs" not in st.session_state:
    st.session_state["sql_execution_logs"] = []

if "pending_query" not in st.session_state:
    st.session_state["pending_query"] = None

@st.cache_resource(show_spinner="Initializing Railway AI Agent...")
def get_railway_agent():
    agent = RailwayAgent()
    agent.load()
    return agent

@st.cache_resource(show_spinner="Initializing Railway Database Connector...")
def get_db_connector():
    connector = OMCSDatabaseConnector()
    connector.is_connected = False  # Start in Offline Schema mode; use sidebar to connect live
    return connector

agent = get_railway_agent()
connector = get_db_connector()

# -----------------------------------------------------------------------------
# 5. MASTER PLOTLY CHART ENGINE FOR RAILWAY
# -----------------------------------------------------------------------------
GRAFANA_PALETTE = ["#f2495c", "#ff780a", "#f2c96d", "#5794f2", "#73bf69", "#b877d9", "#e0b400"]

def build_railway_master_chart(question: str, df: pd.DataFrame):
    if df is None or df.empty:
        return None

    plot_df = df.copy()
    q_lower = question.lower()

    # 1. Alarm Severity Distribution Chart
    if "severity" in q_lower or "perceivedseverity" in [c.lower() for c in plot_df.columns]:
        count_col = next((c for c in plot_df.columns if "count" in c.lower()), None)
        label_col = next((c for c in plot_df.columns if "label" in c.lower() or "severity" in c.lower()), None)

        if count_col and label_col:
            color_map = {
                "Critical": "#f2495c",
                "Major": "#ff780a",
                "Minor": "#f2c96d",
                "Warning": "#5794f2",
                "Indeterminate": "#9ca3af",
                "Cleared": "#73bf69"
            }
            colors = [color_map.get(str(val), "#5794f2") for val in plot_df[label_col]]
            fig = px.pie(
                plot_df,
                names=label_col,
                values=count_col,
                title="<b>📊 Active Alarm Severity Distribution</b>",
                hole=0.45,
                color_discrete_sequence=colors
            )
            fig.update_layout(
                template="plotly_dark",
                paper_bgcolor="#111217",
                plot_bgcolor="#181b1f",
                font=dict(family="sans-serif", color="#d8d9da", size=11),
                legend=dict(orientation="h", yanchor="bottom", y=-0.2, xanchor="center", x=0.5)
            )
            return fig

    # 2. Top Recurring Alarm Frequency Bar Chart
    if "alarm_description" in plot_df.columns and "active_frequency" in plot_df.columns:
        fig = px.bar(
            plot_df.head(10),
            x="active_frequency",
            y="alarm_description",
            orientation="h",
            title="<b>🚨 Top Recurring Active Alarms by Frequency</b>",
            color="active_frequency",
            color_continuous_scale="Reds",
            text="active_frequency"
        )
        fig.update_layout(
            template="plotly_dark",
            paper_bgcolor="#111217",
            plot_bgcolor="#181b1f",
            yaxis=dict(autorange="reversed"),
            font=dict(family="sans-serif", color="#d8d9da", size=11),
            margin=dict(l=30, r=20, t=35, b=30)
        )
        return fig

    # 3. Top MOC / Subsystem Alarm Frequency Bar Chart
    moc_col = next((c for c in plot_df.columns if c.lower() in ["moc", "moi", "nename", "stationname"]), None)
    alarm_cnt = next((c for c in plot_df.columns if "count" in c.lower() or "alarm" in c.lower() or "frequency" in c.lower()), None)
    if moc_col and alarm_cnt:
        fig = px.bar(
            plot_df.head(10),
            x=moc_col,
            y=alarm_cnt,
            title=f"<b>📊 Alarm Concentration by {moc_col.upper()}</b>",
            color=alarm_cnt,
            color_continuous_scale="Reds"
        )
        fig.update_layout(
            template="plotly_dark",
            paper_bgcolor="#111217",
            plot_bgcolor="#181b1f",
            font=dict(family="sans-serif", color="#d8d9da", size=11),
            margin=dict(l=30, r=20, t=35, b=30)
        )
        return fig

    # 4. Numeric Breakdown fallback
    ignore_ids = {"recordid", "neid", "agentid", "eventtime", "loggingtime", "id", "stationid"}
    numeric_cols = [c for c in plot_df.select_dtypes("number").columns if c.lower() not in ignore_ids]
    if numeric_cols:
        x_col = plot_df.columns[0]
        fig = px.bar(
            plot_df.head(15),
            x=x_col,
            y=numeric_cols[0],
            title=f"<b>📈 {numeric_cols[0]} Distribution</b>",
            color_discrete_sequence=["#38bdf8"]
        )
        fig.update_layout(
            template="plotly_dark",
            paper_bgcolor="#111217",
            plot_bgcolor="#181b1f",
            font=dict(family="sans-serif", color="#d8d9da", size=11)
        )
        return fig

    return None

# -----------------------------------------------------------------------------
# 6. SIDEBAR CONTROLS, KNOWLEDGE BASE, LOGS & MEMORY
# -----------------------------------------------------------------------------
with st.sidebar:
    st.markdown("### 🔌 Database Connection")
    conn_status = "Live Connected" if connector.is_connected else "Offline Schema Mode"
    badge_color = "#4ade80" if connector.is_connected else "#38bdf8"
    st.markdown(
        f'<div class="connected-badge" style="color: {badge_color};">'
        f'● <b>{conn_status}</b>: OMCSMGMT_2_0_0 ({connector.host}:{connector.port})'
        f'</div>',
        unsafe_allow_html=True
    )

    with st.expander("⚙️ Connection Settings", expanded=False):
        h = st.text_input("Host", value=DEFAULT_DB_CONFIG["host"])
        p = st.number_input("Port", value=DEFAULT_DB_CONFIG["port"], step=1)
        u = st.text_input("User", value=DEFAULT_DB_CONFIG["user"])
        pwd = st.text_input("Password", value=DEFAULT_DB_CONFIG["password"], type="password")
        d = st.text_input("Database", value=DEFAULT_DB_CONFIG["database"])
        if st.button("Reconnect Database", use_container_width=True):
            connector.host = h
            connector.port = int(p)
            connector.user = u
            connector.password = pwd
            connector.database = d
            ok, msg = connector.connect()
            if ok:
                st.success("Reconnected!")
                st.rerun()
            else:
                st.error(msg)

    st.divider()

    st.markdown("### 🧠 AI Knowledge Base")
    st.caption("Schema dictionary and domain rules for OMCS Railway operations.")
    kb_info = {
        "title": "Railway Central Network Management (OMCSMGMT_2_0_0) Knowledge Base",
        "database": DEFAULT_DB_CONFIG["database"],
        "tables_indexed": 173,
        "fcaps_domains": ["Fault", "Configuration", "Accounting/Asset", "Performance", "Security"],
        "severity_codes": SEVERITY_MAPPING
    }
    st.download_button(
        label="📦 Export Schema KB (.json)",
        data=json.dumps(kb_info, indent=2).encode("utf-8"),
        file_name="railway_knowledge_base.json",
        mime="application/json",
        use_container_width=True
    )

    st.divider()

    st.markdown("### 💾 Persistent Train DB Memory")
    mem_df = load_all_memories_dataframe()
    if not mem_df.empty:
        for idx, row in mem_df.iterrows():
            col1, col2 = st.columns([0.85, 0.15])
            with col1:
                st.caption(f"📌 **[{row['category'].upper()}]** {row['memory_value']}")
            with col2:
                if st.button("🗑️", key=f"del_mem_{row['id']}", help="Delete this rule"):
                    delete_memory_fact(int(row["id"]))
                    st.toast("Fact deleted from railway_train_db!")
                    st.rerun()

        col_m1, col_m2 = st.columns(2)
        with col_m1:
            st.download_button(
                label="📦 Export (.json)",
                data=mem_df.to_json(orient="records", indent=2).encode("utf-8"),
                file_name="railway_train_db_memory.json",
                mime="application/json",
                use_container_width=True
            )
        with col_m2:
            if st.button("💥 Clear All", key="clear_all_mem", use_container_width=True):
                clear_all_memories()
                st.toast("Cleared memory!")
                st.rerun()
    else:
        st.caption("No operational aliases stored in train_db yet.")

    st.divider()

    st.markdown("### 🔍 Live Executed SQL Commands")
    if st.session_state["sql_execution_logs"]:
        for log in reversed(st.session_state["sql_execution_logs"][-5:]):
            st.caption(f"⏱️ **[{log['timestamp']}]** (`{log['time_taken']:.3f}s`)")
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
                    if st.button(f"📌 {prompt[:22]}...", key=f"bm_{folder_name}_{p_idx}", help=prompt, use_container_width=True):
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
# 7. EXECUTION PIPELINE
# -----------------------------------------------------------------------------
def run_pipeline(question: str):
    clean_q = question.strip()
    if not clean_q:
        return

    # Memory triggers
    memory_triggers = ["remember that", "save alias", "note that", "store rule"]
    if any(phrase in clean_q.lower() for phrase in memory_triggers):
        save_memory_fact("rule", "User Preference", clean_q)
        st.session_state["messages"].append({"role": "user", "content": clean_q})
        st.session_state["messages"].append({
            "role": "assistant",
            "content": f"💾 Got it! Stored rule in **railway_train_db**:\n> *\"{clean_q}\"*"
        })
        st.rerun()
        return

    st.session_state["messages"].append({"role": "user", "content": clean_q})

    context = {
        "connector": connector,
        "history": st.session_state["messages"]
    }

    with st.spinner("🤖 Consulting Railway Central Operations Agent..."):
        start_t = time.time()
        try:
            agent_res: AgentExecutionResult = agent.run(
                prompt=clean_q,
                history=st.session_state["messages"],
                context=context
            )
            elapsed = time.time() - start_t
        except Exception as e:
            st.session_state["messages"].append({
                "role": "assistant",
                "content": f"⚠️ Error executing query: {e}",
                "question": clean_q
            })
            st.rerun()
            return

    df = agent_res.dataframes[0] if agent_res.dataframes else pd.DataFrame()
    raw_sql = agent_res.raw_sql

    if raw_sql:
        st.session_state["sql_execution_logs"].append({
            "timestamp": time.strftime("%H:%M:%S"),
            "sql": raw_sql,
            "time_taken": elapsed
        })

    tool_names = [tc["tool"] for tc in agent_res.tool_calls] if agent_res.tool_calls else []

    st.session_state["messages"].append({
        "role": "assistant",
        "content": agent_res.answer,
        "sql": raw_sql or None,
        "df": df if not df.empty else None,
        "question": clean_q,
        "should_plot": agent_res.should_plot,
        "tool_calls": tool_names,
        "latency": round(elapsed, 3)
    })
    st.rerun()

# -----------------------------------------------------------------------------
# 8. MAIN USER INTERFACE
# -----------------------------------------------------------------------------
st.markdown("# 🚆 Railway Network AI Master Agent")
st.caption("Autonomous FCAPS Control Room Operations & Central Management Intelligence (OMCSMGMT_2_0_0)")

if connector.is_connected:
    st.markdown(
        f'<div class="connected-badge">'
        f'🟢 Live Database Connected: <b>{connector.database}</b> on <b>{connector.host}:{connector.port}</b> '
        f'| <b>173 Tables</b> | Model: <b>Qwen 2.5 Coder (7B)</b>'
        f'</div>',
        unsafe_allow_html=True
    )
else:
    st.markdown(
        '<div class="connected-badge" style="border-color: #38bdf8; color: #7dd3fc; background-color: #0f172a;">'
        '🟡 Offline Schema Intelligence Mode: <b>OMCSMGMT_2_0_0_schema.sql</b> '
        '| <b>173 Tables Indexed</b> | Model: <b>Qwen 2.5 Coder (7B)</b>'
        '</div>',
        unsafe_allow_html=True
    )

# Demo Suggestion Chips
st.markdown("**⚡ Quick Operational Actions:**")
chip_col1, chip_col2, chip_col3, chip_col4, chip_col5, chip_col6 = st.columns(6)

with chip_col1:
    if st.button("🔥 Top 5 Alarms", use_container_width=True, help="What are the top 5 most frequent active alarms?"):
        st.session_state["pending_query"] = "What are the top 5 most frequent active alarms?"
        st.rerun()

with chip_col2:
    if st.button("🔴 Critical Alarms", use_container_width=True, help="Show active critical severity 1 alarms"):
        st.session_state["pending_query"] = "Show all active critical alarms"
        st.rerun()

with chip_col3:
    if st.button("📊 Plot Severities", use_container_width=True, help="Plot active alarm severity distribution"):
        st.session_state["pending_query"] = "Plot active alarm severity distribution"
        st.rerun()

with chip_col4:
    if st.button("🟠 Offline Devices", use_container_width=True, help="List all offline network elements"):
        st.session_state["pending_query"] = "List all offline network elements"
        st.rerun()

with chip_col5:
    if st.button("🟢 SNMP Health", use_container_width=True, help="Check recent SNMP polling status"):
        st.session_state["pending_query"] = "What is the current SNMP polling status of all nodes?"
        st.rerun()

with chip_col6:
    if st.button("🏢 Stations List", use_container_width=True, help="List railway stations"):
        st.session_state["pending_query"] = "Show railway stations list"
        st.rerun()

st.divider()

# Chat history container
chat_container = st.container()
with chat_container:
    for idx, msg in enumerate(st.session_state["messages"]):
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

            if "df" in msg and msg["df"] is not None and not msg["df"].empty:
                df = format_dataframe_human_friendly(msg["df"])
                st.dataframe(df, use_container_width=True)

                # Render master chart if requested or detected
                q_text = msg.get("question", "")
                if msg.get("should_plot") or any(k in q_text.lower() for k in ["plot", "chart", "graph", "distribution"]):
                    chart = build_railway_master_chart(q_text, df)
                    if chart is not None:
                        st.plotly_chart(chart, use_container_width=True, key=f"chart_{idx}")

                # JSON export button
                json_bytes = df.to_json(orient="records", date_format="iso", indent=2).encode("utf-8")
                st.download_button(
                    "📋 Export Query Data (.json)",
                    json_bytes,
                    "railway_query_data.json",
                    "application/json",
                    key=f"dl_json_{idx}"
                )

                # Bookmark popover
                if q_text:
                    with st.popover("🔖 Bookmark Prompt"):
                        target_folder = st.selectbox("Folder", list(st.session_state["bookmarks"].keys()), key=f"fold_sel_{idx}")
                        if st.button("Save Bookmark", key=f"save_bm_btn_{idx}"):
                            if q_text not in st.session_state["bookmarks"][target_folder]:
                                st.session_state["bookmarks"][target_folder].append(q_text)
                                save_bookmarks(st.session_state["bookmarks"])
                                st.toast(f"Saved to {target_folder}!")
                                st.rerun()

            # SQL expander if query was executed
            if msg.get("sql"):
                latency_str = f" in {msg['latency']}s" if "latency" in msg else ""
                with st.expander(f"🔍 Executed SQL Query{latency_str}", expanded=False):
                    st.code(msg["sql"], language="sql")

# -----------------------------------------------------------------------------
# 9. INPUT HANDLING
# -----------------------------------------------------------------------------
if st.session_state["pending_query"]:
    q = st.session_state["pending_query"]
    st.session_state["pending_query"] = None
    run_pipeline(q)

user_query = st.chat_input("Ask a question about railway alarms, network elements, stations, or telemetry...")
if user_query:
    run_pipeline(user_query)
S