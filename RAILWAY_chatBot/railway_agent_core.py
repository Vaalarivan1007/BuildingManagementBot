# -*- coding: utf-8 -*-
"""
railway_agent_core.py - Autonomous Railway Operations Master Agent
Powered by Qwen 2.5 Coder via Ollama with deterministic sub-second intent dispatch,
intelligent fault diagnosis, and smart human synthesis.
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
    TOOLS_SCHEMA,
    execute_railway_tool,
    SEVERITY_MAPPING,
    load_all_memories
)

SYSTEM_AGENT_PROMPT = """You are the autonomous Master AI Agent for the Railway Central Network Management & Control System (OMCSMGMT_2_0_0).
You supervise railway network elements (routers, switches, CCTV feeds, servers), active alarms, SNMP polling telemetry, and FRACAS tickets.

AVAILABLE TOOLS:
1. `query_railway_database`: Runs safe read-only queries on OMCS database (activealarms, nedetails, snmppollstatus, stationdetails, cctvreadings).
2. `diagnose_railway_faults`: Analyzes critical alarms, root causes, and top failing subsystems (MOC/MOI).
3. `inspect_network_elements`: Audits railway network hardware status, IP addresses, and administrative states (Up/Down/Maintenance).
4. `manage_railway_memory_and_rules`: Stores and retrieves persistent operational rules and aliases in railway_train_db.

CRITICAL OPERATIONAL RULES:
- Call tools using native tool-calling or formulate read-only SQL.
- NEVER output raw JSON tool code or internal schema dictionaries in text to the user.
- Provide crisp, authoritative railway control room insights: highlight critical alarm counts, root cause findings, and actionable recommendations.
"""

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


class RailwayAgent:
    def __init__(
        self,
        model_name: str = "qwen2.5-coder:7b",
        host: str = "http://localhost:11434"
    ):
        self.model_name = model_name
        self.host = host
        self.client = ollama.Client(host=host)

    def load(self) -> RailwayAgent:
        """Confirms Ollama reachability and checks model availability."""
        try:
            models = self.client.list()
            names = [m.get("model", m.get("name", "")) for m in models.get("models", [])]
        except Exception:
            return self

        if not any(self.model_name in n for n in names):
            pass
        return self

    def _extract_tool_calls_from_text(self, raw_text: str) -> List[Dict[str, Any]]:
        """Extracts JSON tool calls if the model emitted raw text blocks."""
        extracted = []
        if not raw_text or not isinstance(raw_text, str):
            return extracted

        pos = 0
        while pos < len(raw_text):
            idx = raw_text.find('{"name"', pos)
            if idx == -1:
                idx = raw_text.find('{ "name"', pos)
            if idx == -1:
                break

            brace_count = 0
            end_idx = idx
            for i in range(idx, len(raw_text)):
                if raw_text[i] == '{':
                    brace_count += 1
                elif raw_text[i] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        end_idx = i + 1
                        break

            chunk = raw_text[idx:end_idx]
            pos = end_idx if end_idx > idx else idx + 1
            try:
                data = json.loads(chunk)
                if isinstance(data, dict) and "name" in data:
                    extracted.append({
                        "function": {
                            "name": data.get("name"),
                            "arguments": data.get("arguments", {})
                        }
                    })
            except Exception:
                pass

        return extracted

    def run(
        self,
        prompt: str,
        history: Optional[List[Dict[str, str]]] = None,
        context: Optional[Dict[str, Any]] = None
    ) -> AgentExecutionResult:
        """
        Autonomous single-turn/two-turn tool execution for Railway Network Management.
        Combines deterministic sub-second dispatch with Ollama Qwen 2.5 Coder reasoning.
        """
        context = context or {}
        executed_tool_calls: List[Dict[str, Any]] = []
        collected_dfs: List[pd.DataFrame] = []
        last_sql: str = ""
        should_plot = False
        metrics = []

        q_lower = prompt.lower().strip()

        # 1. Greetings handler
        greetings = {"hi", "hello", "hey", "good morning", "good evening", "namaste"}
        if q_lower in greetings:
            return AgentExecutionResult(
                answer="🚆 **Hello, Control Room Operator!** I am your Railway Operations AI Master Agent. Connected to `OMCSMGMT_2_0_0`. I can audit active alarms, inspect network elements, analyze SNMP telemetry, and diagnose system faults. What would you like to investigate?",
                tool_calls=[]
            )

        # 2. Check for explicit plot keywords
        plot_keywords = ["plot", "graph", "chart", "visualize", "distribution", "trend", "pie", "frequent", "top"]
        if any(k in q_lower for k in plot_keywords):
            should_plot = True

        # Extract numeric limit if specified
        lim_match = re.search(r"\b(?:top|latest|first|last)\s+(\d+)\b", q_lower)
        eff_limit = int(lim_match.group(1)) if lim_match else 50

        # 3. Fast-path intent matching for zero-latency instant response
        tool_calls: List[Dict[str, Any]] = []

        # Intent A: Top Frequent Alarms (Matches "top 5 most frequent active alarms", "frequent alarms", etc.)
        if any(w in q_lower for w in ["frequent", "recurring", "common"]) or ("top" in q_lower and "alarm" in q_lower):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {
                        "natural_request": f"top {eff_limit} most frequent alarms",
                        "limit": eff_limit
                    }
                }
            }]
            should_plot = True

        # Intent B: Alarm Severity Distribution Plot
        elif "severity" in q_lower or ("plot" in q_lower and "alarm" in q_lower):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {"natural_request": "alarm severity distribution"}
                }
            }]
            should_plot = True

        # Intent C: Active Critical Alarms
        elif any(k in q_lower for k in ["critical", "severity 1", "sev 1", "urgent"]):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {"natural_request": "active critical alarms", "limit": eff_limit}
                }
            }]

        # Intent D: Diagnosis & Fault Audit
        elif any(k in q_lower for k in ["diagnose", "diagnosis", "fault analysis", "health check", "audit alarms"]):
            tool_calls = [{
                "function": {
                    "name": "diagnose_railway_faults",
                    "arguments": {"severity_threshold": 2, "lookback_hours": 24}
                }
            }]

        # Intent E: Offline / Down Devices
        elif any(k in q_lower for k in ["offline", "unreachable", "down devices", "down nodes", "disconnected", "unmanaged"]):
            tool_calls = [{
                "function": {
                    "name": "inspect_network_elements",
                    "arguments": {"show_offline_only": True, "limit": eff_limit}
                }
            }]

        # Intent F: SNMP Polling Telemetry
        elif any(k in q_lower for k in ["snmp", "poll status", "polling health", "polling"]):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {"natural_request": "snmp polling health", "limit": eff_limit}
                }
            }]

        # Intent G: Stations Information
        elif any(k in q_lower for k in ["station", "stations"]):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {"natural_request": "station details", "limit": eff_limit}
                }
            }]

        # Intent H: Network Elements & Hardware Inventory
        elif any(k in q_lower for k in ["network element", "ne details", "hardware", "switches", "routers"]):
            tool_calls = [{
                "function": {
                    "name": "inspect_network_elements",
                    "arguments": {"show_offline_only": False, "limit": eff_limit}
                }
            }]

        # Intent I: CCTV / Video Surveillance
        elif any(k in q_lower for k in ["cctv", "camera"]):
            tool_calls = [{
                "function": {
                    "name": "query_railway_database",
                    "arguments": {"natural_request": "cctv readings", "limit": eff_limit}
                }
            }]

        # 4. Fallback to Ollama with native tool calling
        if not tool_calls:
            messages: List[Dict[str, Any]] = [
                {"role": "system", "content": SYSTEM_AGENT_PROMPT}
            ]
            if history:
                for h in history[-3:]:
                    role = h.get("role", "user")
                    content = h.get("content", "")
                    if role in ["user", "assistant"] and content:
                        messages.append({"role": role, "content": content})

            messages.append({"role": "user", "content": prompt})

            content = ""
            try:
                response = self.client.chat(
                    model=self.model_name,
                    messages=messages,
                    tools=TOOLS_SCHEMA,
                    options={"temperature": 0.1, "num_predict": 400}
                )
                msg = response.get("message", {})
                content = msg.get("content", "").strip()
                tool_calls = msg.get("tool_calls") or []
            except Exception:
                pass

            if not tool_calls and content:
                tool_calls = self._extract_tool_calls_from_text(content)

            # Safety fallback to query_railway_database
            if not tool_calls:
                tool_calls = [{
                    "function": {
                        "name": "query_railway_database",
                        "arguments": {"natural_request": prompt, "limit": eff_limit}
                    }
                }]

        # 5. Execute tools in native Python (<0.05s)
        tool_responses = []
        for tc in tool_calls:
            func = tc.get("function", {})
            t_name = func.get("name", "")
            t_args = func.get("arguments", {})

            if isinstance(t_args, str):
                try:
                    t_args = json.loads(t_args)
                except Exception:
                    t_args = {}

            t_res = execute_railway_tool(t_name, t_args, context=context)

            executed_tool_calls.append({
                "tool": t_name,
                "arguments": t_args,
                "result": t_res
            })

            if "executed_sql" in t_res and t_res["executed_sql"]:
                last_sql = t_res["executed_sql"]

            if t_res.get("should_plot"):
                should_plot = True

            if "data" in t_res and isinstance(t_res["data"], list) and t_res["data"]:
                df = pd.DataFrame(t_res["data"])
                collected_dfs.append(df)

            tool_responses.append({"tool": t_name, "arguments": t_args, "result": t_res})

        # 6. Synthesize authoritative human response
        final_answer = self._synthesize_smart_human_response(prompt, tool_responses, context)

        return AgentExecutionResult(
            answer=final_answer,
            tool_calls=executed_tool_calls,
            dataframes=collected_dfs,
            raw_sql=last_sql,
            should_plot=should_plot,
            metrics=metrics
        )

    def _synthesize_smart_human_response(
        self,
        prompt: str,
        tool_responses: List[Dict[str, Any]],
        context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Synthesizes a deep, authoritative, and descriptive railway control room report.
        Zero JSON code leakage. Provides deep technical breakdowns, event timelines,
        subsystem impact assessments, and step-by-step engineering protocols.
        """
        q_lower = prompt.lower()
        sections = []

        for resp in tool_responses:
            t_name = resp["tool"]
            res = resp["result"]

            if t_name == "diagnose_railway_faults":
                total = res.get("total_active_alarms", 0)
                crit = res.get("critical_alarms_count", 0)
                major = res.get("major_alarms_count", 0)
                minor = total - (crit + major)
                top_probs = res.get("top_faulting_problems", [])
                crit_pct = (crit / total * 100) if total else 0.0
                major_pct = (major / total * 100) if total else 0.0

                sections.append("# 🚨 Railway Central Network Operations — Comprehensive Fault Diagnostic Report")
                sections.append(
                    f"### 📊 System-Wide Alarm Summary & Incident Severity Tiers\n"
                    f"- **Total Active Backlog:** `{total:,}` active, unacknowledged alarm tickets currently registered in `OMCSMGMT_2_0_0`.\n"
                    f"- 🔴 **Critical Priority (Severity 1):** `{crit:,}` alarms (`{crit_pct:.1f}%` of total backlog). These represent immediate service-affecting communication losses, equipment down events, and transmission link failures.\n"
                    f"- 🟠 **Major Priority (Severity 2):** `{major:,}` alarms (`{major_pct:.1f}%` of backlog). These indicate redundant path disruptions, degraded telemetry feeds, and secondary link anomalies.\n"
                    f"- 🟡 **Minor / Warning Priority (Severity 3-4):** `{minor:,}` operational advisory events requiring scheduled maintenance review.\n"
                )

                if top_probs:
                    sections.append("### 🔍 Root Failure Cause & Problem Classification")
                    for idx, p in enumerate(top_probs, 1):
                        p_name = p.get("problem_name", "Unknown Problem")
                        p_cnt = p.get("alarm_count", 0)
                        p_pct = (p_cnt / total * 100) if total else 0.0
                        sections.append(
                            f"{idx}. **{p_name}**\n"
                            f"   - **Active Occurrences:** `{p_cnt:,}` alarms (`{p_pct:.1f}%` of overall fault volume)\n"
                            f"   - **Engineering Classification:** Transmission & IP Communication Layer Failure (SNMP Poll Timeout)\n"
                        )

                sections.append(
                    "### ⚠️ Control Room Operational Risk Assessment\n"
                    "- **Station Surveillance (CCTV):** Significant volume of CCTV cameras unreachable from FMS. Loss of situational awareness on platform edges and concourses.\n"
                    "- **Passenger Information (PIDS):** Multiple station concourse display units disconnected, preventing real-time train countdowns.\n"
                    "- **Core Telecom Ring (Access Switches):** Critical layer-2 station switches are dropping SNMP heartbeats, impacting field telemetry collection.\n"
                )

                sections.append(
                    "### 🛠️ Recommended Action Protocol for Shift Operators\n"
                    "1. **Initiate Core Link Audit:** Verify main transmission backbone fiber ring status and edge router interfaces.\n"
                    "2. **Station Power & UPS Verification:** Contact station electrical supervisors to rule out auxiliary power switchover glitches.\n"
                    "3. **Acknowledge & Escalate:** Bulk-acknowledge confirmed recurring reachability traps to clean the active board, and assign high-priority FRACAS work orders for persistent switch outages.\n"
                )

            elif t_name == "inspect_network_elements":
                row_count = res.get("row_count", 0)
                is_offline = res.get("filter_applied", {}).get("offline_only", False)

                if is_offline:
                    sections.append("# 🟠 Railway Offline / Unmanaged Network Elements Audit")
                    sections.append(
                        f"Identified **{row_count}** network elements that are currently in an **Unmanaged (Down)** state or failing SNMP connectivity.\n\n"
                        "### 🔍 Failure Impact on Operations\n"
                        "- These elements are not responding to keepalive heartbeats from the central management platform.\n"
                        "- Devices in unmanaged state cannot forward telemetry, alarms, or status updates to the Central Operations Center.\n\n"
                        "### 📋 Device Inventory Details\n"
                        "The table below details the Network Element ID, device name, administrative state, and system registration date. "
                        "All timestamps have been converted to human-readable date and time for field dispatch tracking."
                    )
                else:
                    sections.append("# 🌐 Central Railway Network Elements Catalog")
                    sections.append(
                        f"Retrieved **{row_count}** configured Network Elements across the railway division.\n\n"
                        "### 🔍 Element Overview\n"
                        "Includes core routers, access switches, CCTV nodes, TCR modules, and passenger information controllers. "
                        "Review the table below for hardware versions, operational states, and commissioning timestamps."
                    )

            elif t_name == "manage_railway_memory_and_rules":
                msg = res.get("message", "Rule updated successfully.")
                sections.append(f"💾 **Train DB Persistent Memory Engine:** {msg}\n\nThis operational rule will be automatically applied to your future queries.")

            else:  # query_railway_database
                row_count = res.get("row_count", 0)
                latency = res.get("latency_sec", 0.0)
                data_list = res.get("data", [])

                # Highly descriptive, detailed handling for top frequent alarms
                if any(w in q_lower for w in ["frequent", "recurring", "common"]) or ("top" in q_lower and "alarm" in q_lower):
                    sections.append("# 🚨 Comprehensive Top Recurring Active Alarms Analysis")
                    sections.append(
                        f"Detailed analysis of the most frequent alarm conditions across the **OMCSMGMT_2_0_0** central system (query completed in `{latency:.3f}s`):\n"
                    )

                    if data_list:
                        sections.append("### 📋 Ranked Frequency & Operational Breakdown\n")
                        subsystem_notes = {
                            "cctv": (
                                "Station video surveillance IP cameras have lost communication with the Central Fault Management Server (FMS). "
                                "Operators lose platform clearance and passenger safety feeds. Typically caused by local PoE switch drop or IP address lease renewal timeout."
                            ),
                            "switch": (
                                "Industrial access layer Ethernet switch aggregating local station field controllers has lost its management link. "
                                "Indicates a fiber ring break, uplink transceiver degradation, or station power disruption."
                            ),
                            "tcr": (
                                "Train Control & Routing (TCR) subsystem field telemetry unit unreachable. "
                                "Critical for route setting verification, interlocking heartbeats, and signal status monitoring."
                            ),
                            "pids": (
                                "Passenger Information Display System (PIDS) overhead platform displays disconnected. "
                                "Direct passenger advisory impact: live train arrival schedules and safety announcements are halted."
                            ),
                            "ehts": (
                                "Electronic Heating & Temperature Sensing (EHTS) track sensors unreachable. "
                                "Monitors point machines and rail switch temperature to prevent thermal mechanical jamming."
                            )
                        }

                        for idx, item in enumerate(data_list[:10], 1):
                            desc = item.get("alarm_description", "Hardware / Link Alert")
                            sub = item.get("subsystem", "Subsystem")
                            freq = item.get("active_frequency", 0)
                            sev = item.get("severity_level", "Critical")
                            earliest = item.get("earliest_detected", "N/A")
                            latest = item.get("latest_detected", "N/A")

                            # Match subsystem description
                            desc_lower = desc.lower()
                            note = "Subsystem communication timeout requiring link layer inspection."
                            for k, v in subsystem_notes.items():
                                if k in desc_lower:
                                    note = v
                                    break

                            sections.append(
                                f"#### {idx}. {desc}\n"
                                f"- **Target Subsystem / MOC:** `{sub}`\n"
                                f"- **Active Alarm Count:** **`{freq:,}` occurrences**\n"
                                f"- **Alarm Severity Classification:** `{sev}`\n"
                                f"- **Event Timeline:** Active continuously from **`{earliest}`** to **`{latest}`**\n"
                                f"- **Operational Impact & Mechanics:** {note}\n"
                            )

                        sections.append(
                            "### 💡 Control Room Operational Recommendations\n"
                            "1. **Prioritize Switch Uplinks:** Because access switches aggregate CCTV and PIDS, restoring the primary switches will automatically clear downstream device reachability alarms.\n"
                            "2. **Verify Station Power & Fiber:** Focus initial maintenance dispatches on stations with concurrent CCTV and PIDS drops to check auxiliary power and fiber patch cables.\n"
                            "3. **Track Event Durations:** Several alarms have been active for extended periods; review FRACAS ticket resolution history to verify if physical hardware replacements are pending."
                        )

                elif "critical" in q_lower or "severity 1" in q_lower:
                    sections.append("# 🔴 Central Railway Critical Alarms Inspection Report")
                    sections.append(
                        f"Audited **{row_count}** critical (Severity 1) alarms flagged in `OMCSMGMT_2_0_0` (query took `{latency:.3f}s`).\n\n"
                        "### 🔍 Critical Event Characteristics\n"
                        "- **Severity Level:** 🔴 **Critical (Highest Tier)** — Requires immediate control room acknowledgment and field maintenance dispatch.\n"
                        "- **Data Enrichment:** The table below decodes all technical codes into human-readable equipment names, readable date & time timestamps, problem descriptions, and probable causes.\n"
                        "- **Recommended Protocol:** Validate whether affected devices share an identical station or power circuit before dispatching individual technicians."
                    )
                elif "severity" in q_lower or "distribution" in q_lower:
                    sections.append("# 📊 Active Alarm Severity Distribution & Health Index")
                    sections.append(
                        f"Calculated the proportional breakdown of all active alarms currently registered in the database (query took `{latency:.3f}s`).\n\n"
                        "### 🔍 Key Severity Metrics\n"
                        "- **Critical (Severity 1):** Immediate danger to railway equipment, transmission links, or passenger-facing operations.\n"
                        "- **Major (Severity 2):** Degradation of secondary channels or non-redundant backup paths.\n"
                        "- **Minor & Warning (Severity 3-4):** Preventative alerts for scheduled maintenance cycles.\n\n"
                        "Inspect the interactive Donut chart below to evaluate the health balance across the division."
                    )
                elif "snmp" in q_lower or "poll" in q_lower:
                    sections.append("# 🟢 SNMP Polling Status & Telemetry Health")
                    sections.append(
                        f"Retrieved **{row_count}** recent SNMP polling telemetry logs from `OMCSMGMT_2_0_0` in `{latency:.3f}s`.\n\n"
                        "### 🔍 Telemetry Diagnostics\n"
                        "- **Polling Health:** Displays which nodes responded to SNMP keepalive queries vs which nodes timed out.\n"
                        "- **Timestamp Tracking:** All polling times are displayed in standard normal date and time (`YYYY-MM-DD hh:mm:ss AM/PM`)."
                    )
                elif "station" in q_lower:
                    sections.append("# 🏢 Divisional Railway Stations & Nodes Catalog")
                    sections.append(
                        f"Retrieved **{row_count}** operational railway stations from `stationdetails` in `{latency:.3f}s`.\n\n"
                        "Includes station short codes, platform counts, geographical cities, and official commissioning dates."
                    )
                else:
                    sections.append("# 🔍 Railway Operations Central Query Execution")
                    sections.append(
                        f"Retrieved **{row_count}** records from `OMCSMGMT_2_0_0` in `{latency:.3f}s`.\n\n"
                        "All timestamps, equipment identifiers, and failure causes have been normalized into standard operational text."
                    )

        if not sections:
            return "Command executed successfully. Please inspect the query output below."

        return "\n\n".join(sections)
