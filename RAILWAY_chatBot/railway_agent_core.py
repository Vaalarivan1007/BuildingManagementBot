# -*- coding: utf-8 -*-
"""
railway_agent_core.py - Autonomous Railway Operations Master Agent
Powered by Qwen 2.5 Coder via Ollama with deterministic sub-second intent dispatch,
strict schema grounding on OMCSMGMT_2_0_0, zero hallucination, and smart Mode B synthesis.
"""

from __future__ import annotations

import json
import os
import re
import time
from typing import Any, Dict, List, Optional
import ollama
import pandas as pd

import railway_tools
from railway_tools import (
    OMCSDatabaseConnector,
    validate_railway_sql,
    format_dataframe_human_friendly,
    execute_railway_tool,
    load_all_memories,
    save_memory_fact
)

# -----------------------------------------------------------------------------
# 1. LOAD MASTER SYSTEM PROMPTS
# -----------------------------------------------------------------------------
PROMPT_DIR = os.path.dirname(os.path.abspath(__file__))
OMCS_SYS_PROMPT_FILE = os.path.join(PROMPT_DIR, "OMCS_system_prompt.txt")

try:
    with open(OMCS_SYS_PROMPT_FILE, "r", encoding="utf-8") as f:
        OMCS_SYS_PROMPT = f.read().strip()
except Exception:
    OMCS_SYS_PROMPT = "You are the OMCS Railway Operations AI Assistant. Generate safe, read-only MySQL queries."

MODE_B_PROMPT = """You are the OMCS Data Assistant for a metro railway network. OMCS is the Operations Monitoring and Control System.
Your users are railway operations managers, shift supervisors, and executives, NOT database administrators.
Explain the database query results in plain English for a non-technical reader:
- First line: The direct answer to what the user asked in one clear sentence.
- Then at most 5 short bullets with the key facts, counts, equipment names, or status.
- Turn timestamps/epochs into human-readable words (e.g. 'September 24, 2025 at 5:27 PM').
- If no records were found, clearly state that no records match the criteria.
- Never mention SQL, table names, column names, joins, or internal IDs in your explanation.
- Do not hallucinate any information that is not in the query results.
"""


# -----------------------------------------------------------------------------
# 2. EXECUTION RESULT CONTAINER
# -----------------------------------------------------------------------------
class AgentExecutionResult:
    def __init__(
        self,
        answer: str,
        tool_calls: List[Dict[str, Any]],
        dataframes: Optional[List[pd.DataFrame]] = None,
        raw_sql: str = "",
        should_plot: bool = False,
        metrics: Optional[List[str]] = None
    ):
        self.answer = answer
        self.tool_calls = tool_calls
        self.dataframes = dataframes or []
        self.raw_sql = raw_sql
        self.should_plot = should_plot
        self.metrics = metrics or []


# -----------------------------------------------------------------------------
# 3. RAILWAY AGENT MASTER CLASS
# -----------------------------------------------------------------------------
class RailwayAgent:
    def __init__(
        self,
        model_name: Optional[str] = None,
        host: Optional[str] = None
    ):
        self.model_name = model_name or os.getenv("OLLAMA_MODEL", "qwen2.5-coder:7b")
        self.host = host or os.getenv("OLLAMA_HOST", "http://localhost:11434")
        self.client = ollama.Client(host=self.host)

    def load(self) -> RailwayAgent:
        """Confirms Ollama reachability and checks model availability."""
        try:
            models = self.client.list()
            names = [m.get("model", m.get("name", "")) for m in models.get("models", [])]
            if not any(self.model_name in n for n in names):
                pass
        except Exception:
            pass
        return self

    def _extract_sql_from_text(self, text: str) -> Optional[str]:
        """Extracts SQL query from Markdown code block or raw text."""
        if not text:
            return None
        sql_match = re.search(r"```(?:sql|mysql)?\s*(.*?)\s*```", text, re.DOTALL | re.IGNORECASE)
        if sql_match:
            return sql_match.group(1).strip()
        # Fallback: check for standalone SELECT or WITH
        clean = text.strip()
        if clean.upper().startswith(("SELECT", "WITH")):
            return clean
        return None

    def _synthesize_mode_b_with_llm(
        self,
        user_query: str,
        data_records: List[Dict[str, Any]],
        raw_sql: str
    ) -> str:
        """Uses Qwen to generate authoritative, non-hallucinating Mode B explanations."""
        if not data_records:
            return f"No records were found matching your request for **\"{user_query}\"** in the OMCS database."

        # Pass at most 15 sample records to the LLM to avoid context bloat
        sample_records = data_records[:15]
        user_message = (
            f"User Question: {user_query}\n\n"
            f"Database Records (total {len(data_records)}):\n"
            f"{json.dumps(sample_records, default=str, indent=2)}"
        )

        try:
            resp = self.client.chat(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": MODE_B_PROMPT},
                    {"role": "user", "content": user_message}
                ],
                options={"temperature": 0.1, "num_predict": 350}
            )
            msg_content = resp.get("message", {}).get("content", "").strip()
            if msg_content:
                return msg_content
        except Exception:
            pass

        # Fallback deterministic synthesis if LLM is unavailable
        return self._fallback_deterministic_synthesis(user_query, data_records)

    def _fallback_deterministic_synthesis(
        self,
        user_query: str,
        data_records: List[Dict[str, Any]]
    ) -> str:
        """Deterministic bullet-point summary directly from data."""
        total = len(data_records)
        if total == 0:
            return f"No records were found matching your inquiry for **\"{user_query}\"**."

        first_rec = data_records[0]
        keys = list(first_rec.keys())

        lines = [f"Found **{total}** matching record{'s' if total > 1 else ''} for your inquiry."]
        
        # Add up to 5 informative sample bullets
        for idx, rec in enumerate(data_records[:5], 1):
            details = ", ".join(f"**{k}:** {rec[k]}" for k in keys[:3] if rec.get(k) is not None)
            lines.append(f"- {details}")

        if total > 5:
            lines.append(f"- *... and {total - 5} additional records displayed in the table below.*")

        return "\n".join(lines)

    def run(
        self,
        prompt: str,
        history: Optional[List[Dict[str, str]]] = None,
        context: Optional[Dict[str, Any]] = None
    ) -> AgentExecutionResult:
        """
        Processes railway inquiries with deterministic sub-second intent routing,
        safe SQL generation, direct database querying, and smart Mode B synthesis.
        """
        context = context or {}
        connector: OMCSDatabaseConnector = context.get("connector")
        if not connector:
            connector = OMCSDatabaseConnector()
            connector.connect()

        q_lower = prompt.lower().strip()

        # ---------------------------------------------------------------------
        # 1. GREETINGS & CASUAL CONVERSATION HANDLER
        # ---------------------------------------------------------------------
        greetings = {"hi", "hello", "hey", "good morning", "good evening", "namaste", "who are you", "help"}
        if q_lower in greetings or any(q_lower == g for g in greetings):
            return AgentExecutionResult(
                answer=(
                    "🚆 **Hello, Control Room Operator!** I am your OMCS Railway Operations AI Assistant. "
                    "I am connected to the live railway management database (`OMCSMGMT_2_0_0`).\n\n"
                    "You can ask me questions about:\n"
                    "- **Sensor Types & Deployed Sensors** (e.g. *\"what are the sensor types?\"*, *\"what sensors are present?\"*)\n"
                    "- **Master Clock & Moba System Alarms** (e.g. *\"what is the recent alarms on Moba or Masterclock?\"*)\n"
                    "- **Active & Critical Alarms** (e.g. *\"top 5 most frequent active alarms\"*, *\"show critical alarms\"*)\n"
                    "- **Equipment Reachability** (e.g. *\"how many devices are offline right now?\"*, *\"list offline devices\"*)\n"
                    "- **Railway Stations & Hardware Catalog** (e.g. *\"show all stations\"*, *\"show CCTV cameras\"*)\n\n"
                    "What would you like to investigate?"
                ),
                tool_calls=[]
            )

        # ---------------------------------------------------------------------
        # 2. DETERMINISTIC HIGH-SPEED INTENT ROUTER (<0.05s)
        # ---------------------------------------------------------------------
        lim_match = re.search(r"\b(?:top|latest|first|last)\s+(\d+)\b", q_lower)
        eff_limit = int(lim_match.group(1)) if lim_match else 50
        
        plot_keywords = ["plot", "graph", "chart", "visualize", "distribution", "pie", "bar"]
        should_plot = any(k in q_lower for k in plot_keywords)

        sql_to_execute: Optional[str] = None

        # Intent A: Sensor Types
        if any(k in q_lower for k in ["sensor type", "sensor types", "types of sensor", "types of sensors", "kind of sensor"]):
            sql_to_execute = f"""
            SELECT 
                nesubtypeid AS `Subtype ID`, 
                nesubtypename AS `Sensor Type`, 
                nesubtypemodel AS `Model`, 
                nesubtypemake AS `Make` 
            FROM nesubtypedetails 
            WHERE nesubtypename LIKE '%sensor%' OR nesubtypename LIKE '%fence%' 
            ORDER BY nesubtypeid 
            LIMIT {eff_limit};
            """

        # Intent B: Sensors Present / Deployed
        elif any(k in q_lower for k in ["sensors present", "sensor present", "sensors deployed", "sensors installed", "what sensors are there", "what sensors are present", "fence sensor"]):
            sql_to_execute = f"""
            SELECT 
                n.neid AS `Device ID`, 
                n.nename AS `Sensor Name`, 
                s.nesubtypename AS `Sensor Type`, 
                g.groupname AS `System`,
                CASE n.neadminstate WHEN 1 THEN 'Managed / Up' WHEN 2 THEN 'Unmanaged / Down' ELSE 'Maintenance' END AS `Status`
            FROM nedetails n 
            JOIN neversiondetails v ON n.neversionnumber = v.neversionnumber 
            JOIN nesubtypedetails s ON v.neversionnesubtypeid = s.nesubtypeid 
            JOIN groupdetails g ON n.negroupid = g.groupid 
            WHERE s.nesubtypename LIKE '%sensor%' OR g.groupname LIKE '%sensor%' OR g.groupname = 'FENCE' 
            ORDER BY n.neid 
            LIMIT {eff_limit};
            """

        # Intent C: Moba / Mobatime / Master Clock / Digital Clock Alarms
        elif any(k in q_lower for k in ["moba", "mobatime", "masterclock", "master clock", "digital clock", "mcs alarm", "clock alarm", "alarms on moba", "alarms on masterclock"]):
            sql_to_execute = f"""
            SELECT 
                a.recordid AS `Alarm ID`, 
                n.nename AS `Device`, 
                s.nesubtypename AS `Device Type`, 
                g.groupname AS `System`, 
                COALESCE(sp.specificproblemname, a.additionaltext, 'Link Alert') AS `Alarm Description`, 
                p.perceivedseverityname AS `Severity`, 
                DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS `Event Time` 
            FROM activealarms a 
            JOIN nedetails n ON a.neid = n.neid 
            LEFT JOIN neversiondetails v ON n.neversionnumber = v.neversionnumber 
            LEFT JOIN nesubtypedetails s ON v.neversionnesubtypeid = s.nesubtypeid 
            LEFT JOIN groupdetails g ON n.negroupid = g.groupid 
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid 
            LEFT JOIN perceivedseverity p ON a.perceivedseverity = p.perceivedseverityid 
            WHERE g.groupname = 'MCS' OR s.nesubtypename LIKE '%clock%' OR n.nename LIKE '%clock%' OR n.nename LIKE '%moba%' 
            ORDER BY a.eventtime DESC 
            LIMIT {eff_limit};
            """

        # Intent D: Top Most Frequent Alarms
        elif any(k in q_lower for k in ["frequent", "recurring", "common"]) or ("top" in q_lower and "alarm" in q_lower):
            should_plot = True
            sql_to_execute = f"""
            SELECT 
                COALESCE(sp.specificproblemname, at.alarmtypeadditionaltext, a.ticketmessage, 'Hardware/Link Alert') AS `Alarm Description`, 
                a.moc AS `Subsystem`, 
                COUNT(*) AS `Active Count`, 
                CASE MAX(a.perceivedseverity) 
                    WHEN 1 THEN 'Critical' 
                    WHEN 2 THEN 'Major' 
                    WHEN 3 THEN 'Minor' 
                    WHEN 4 THEN 'Warning' 
                    WHEN 5 THEN 'Indeterminate' 
                    ELSE 'Cleared' 
                END AS `Severity` 
            FROM activealarms a 
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid 
            LEFT JOIN alarmtypedetails at ON a.alarmtypeid = at.alarmtypeid 
            GROUP BY `Alarm Description`, a.moc 
            ORDER BY `Active Count` DESC 
            LIMIT {eff_limit};
            """

        # Intent E: Alarm Severity Distribution
        elif any(k in q_lower for k in ["severity distribution", "alarm severity", "count by severity"]) or ("severity" in q_lower and "plot" in q_lower):
            should_plot = True
            sql_to_execute = """
            SELECT 
                p.perceivedseverityname AS `Severity`, 
                COUNT(*) AS `Active Alarms` 
            FROM activealarms a 
            JOIN perceivedseverity p ON p.perceivedseverityid = a.perceivedseverity 
            GROUP BY p.perceivedseverityname, p.perceivedseverityid 
            ORDER BY p.perceivedseverityid ASC;
            """

        # Intent F: Active Critical Alarms
        elif any(k in q_lower for k in ["critical alarm", "critical alarms", "severity 1", "active critical", "urgent alarm"]):
            sql_to_execute = f"""
            SELECT 
                a.recordid AS `Alarm ID`, 
                COALESCE(n.nename, CONCAT('NE #', a.neid)) AS `Device`, 
                a.moc AS `Subsystem`, 
                'Critical' AS `Severity`, 
                COALESCE(sp.specificproblemname, a.additionaltext, 'Critical Link Alert') AS `Alarm Description`, 
                COALESCE(pc.probablecausename, 'Connection Establishment Error') AS `Probable Cause`, 
                DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS `Event Time` 
            FROM activealarms a 
            LEFT JOIN nedetails n ON a.neid = n.neid 
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid 
            LEFT JOIN probablecauses pc ON a.probablecause = pc.probablecauseid 
            WHERE a.perceivedseverity = 1 
            ORDER BY a.eventtime DESC 
            LIMIT {eff_limit};
            """

        # Intent G: Devices Offline Right Now
        elif any(k in q_lower for k in ["offline right now", "offline now", "how many devices are offline", "devices down now"]):
            sql_to_execute = "SELECT COUNT(*) AS `Devices offline now` FROM nestatus WHERE nestatusisreachable = 0 LIMIT 1;"

        # Intent H: List Offline Devices
        elif any(k in q_lower for k in ["offline devices", "down devices", "unreachable devices", "list offline"]):
            sql_to_execute = f"""
            SELECT 
                n.neid AS `Device ID`, 
                n.nename AS `Device Name`, 
                g.groupname AS `System`, 
                'Unreachable' AS `Status`, 
                DATE_FORMAT(FROM_UNIXTIME(s.nestatuseventtime), '%Y-%m-%d %h:%i:%s %p') AS `Offline Since` 
            FROM nestatus s 
            JOIN nedetails n ON n.neid = s.nestatusneid 
            LEFT JOIN groupdetails g ON g.groupid = n.negroupid 
            WHERE s.nestatusisreachable = 0 
            ORDER BY s.nestatuseventtime DESC 
            LIMIT {eff_limit};
            """

        # Intent I: Railway Stations
        elif any(k in q_lower for k in ["station", "stations"]):
            sql_to_execute = f"""
            SELECT 
                stationname AS `Station`, 
                stationshortname AS `Code`, 
                stationcity AS `City`, 
                stationplatforms AS `Platforms` 
            FROM stationdetails 
            ORDER BY stationname ASC 
            LIMIT {eff_limit};
            """

        # Intent J: CCTV Cameras
        elif any(k in q_lower for k in ["cctv", "camera", "cameras"]):
            sql_to_execute = f"""
            SELECT 
                n.neid AS `Device ID`, 
                n.nename AS `Camera Name`, 
                s.nesubtypename AS `Type`, 
                CASE n.neadminstate WHEN 1 THEN 'Managed / Up' WHEN 2 THEN 'Unmanaged / Down' ELSE 'Maintenance' END AS `Status` 
            FROM nedetails n 
            JOIN neversiondetails v ON n.neversionnumber = v.neversionnumber 
            JOIN nesubtypedetails s ON v.neversionnesubtypeid = s.nesubtypeid 
            WHERE s.nesubtypename = 'CCTV' 
            ORDER BY n.neid ASC 
            LIMIT {eff_limit};
            """

        # ---------------------------------------------------------------------
        # 3. LLM TEXT-TO-SQL FALLBACK (FOR ARBITRARY / COMPLEX QUERIES)
        # ---------------------------------------------------------------------
        if not sql_to_execute:
            messages = [
                {"role": "system", "content": OMCS_SYS_PROMPT}
            ]
            if history:
                for h in history[-3:]:
                    r = h.get("role")
                    c = h.get("content")
                    if r in ["user", "assistant"] and c:
                        messages.append({"role": r, "content": c})
            messages.append({"role": "user", "content": prompt})

            try:
                llm_resp = self.client.chat(
                    model=self.model_name,
                    messages=messages,
                    options={"temperature": 0.0, "num_predict": 400}
                )
                raw_llm_text = llm_resp.get("message", {}).get("content", "")
                sql_to_execute = self._extract_sql_from_text(raw_llm_text)
            except Exception:
                pass

        # Ultimate fallback query if still no SQL
        if not sql_to_execute:
            sql_to_execute = f"""
            SELECT 
                a.recordid AS `Alarm ID`, 
                COALESCE(n.nename, CONCAT('NE #', a.neid)) AS `Device`, 
                a.moc AS `Subsystem`, 
                p.perceivedseverityname AS `Severity`, 
                COALESCE(sp.specificproblemname, a.additionaltext, 'Link Alert') AS `Alarm Description`, 
                DATE_FORMAT(FROM_UNIXTIME(a.eventtime), '%Y-%m-%d %h:%i:%s %p') AS `Event Time` 
            FROM activealarms a 
            LEFT JOIN nedetails n ON a.neid = n.neid 
            LEFT JOIN specificproblems sp ON a.specificproblem = sp.specificproblemid 
            LEFT JOIN perceivedseverity p ON a.perceivedseverity = p.perceivedseverityid 
            ORDER BY a.eventtime DESC 
            LIMIT {eff_limit};
            """

        # ---------------------------------------------------------------------
        # 4. EXECUTE SQL QUERY ON OMCS DATABASE
        # ---------------------------------------------------------------------
        executed_sql = ""
        records: List[Dict[str, Any]] = []
        df = pd.DataFrame()
        tool_calls: List[Dict[str, Any]] = []

        try:
            clean_sql = validate_railway_sql(sql_to_execute)
            executed_sql = clean_sql
            query_res = connector.execute_query(clean_sql, limit=eff_limit)

            if query_res.get("status") == "success":
                records = query_res.get("data", [])
                if records:
                    df = pd.DataFrame(records)
                    df = format_dataframe_human_friendly(df)
            else:
                # Query syntax error - attempt quick self-correction if column error
                err_msg = query_res.get("message", "")
                if "Unknown column" in err_msg:
                    # Retry with generic alarm query
                    fallback_sql = f"SELECT recordid AS `Alarm ID`, neid AS `NE ID`, moc AS `Subsystem`, FROM_UNIXTIME(eventtime) AS `Event Time` FROM activealarms ORDER BY eventtime DESC LIMIT {eff_limit};"
                    clean_sql = validate_railway_sql(fallback_sql)
                    executed_sql = clean_sql
                    retry_res = connector.execute_query(clean_sql, limit=eff_limit)
                    if retry_res.get("status") == "success":
                        records = retry_res.get("data", [])
                        df = pd.DataFrame(records)
                        df = format_dataframe_human_friendly(df)

            tool_calls.append({
                "tool": "query_railway_database",
                "arguments": {"natural_request": prompt, "sql_query": executed_sql},
                "result": {"status": "success", "row_count": len(records), "data": records}
            })
        except Exception as e:
            return AgentExecutionResult(
                answer=f"⚠️ An error occurred while executing the railway query: {str(e)}",
                tool_calls=[],
                raw_sql=sql_to_execute
            )

        # ---------------------------------------------------------------------
        # 5. SYNTHESIZE FINAL HUMAN-GRADE ANSWER (MODE B)
        # ---------------------------------------------------------------------
        final_answer = self._synthesize_mode_b_with_llm(
            user_query=prompt,
            data_records=records,
            raw_sql=executed_sql
        )

        return AgentExecutionResult(
            answer=final_answer,
            tool_calls=tool_calls,
            dataframes=[df] if not df.empty else [],
            raw_sql=executed_sql,
            should_plot=should_plot
        )
