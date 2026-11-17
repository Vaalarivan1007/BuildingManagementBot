"""
agent_core.py - Fast, Autonomous BMS Master Agent with Streamlined Dynamic Tool Calling
Powered by Qwen 2.5 Coder via Ollama (Zero Latency Overhead & Deterministic Dispatch).
"""

from __future__ import annotations

import json
import re
import time
from typing import Any, Dict, List, Optional
import ollama
import pandas as pd

import bms_tools
from bms_tools import TOOLS_SCHEMA, execute_tool

SYSTEM_AGENT_PROMPT = """You are the autonomous Master AI Agent for a Building Management System (BMS).
You monitor multi-phase electrical telemetry (voltages, currents, temperatures, energy) and OPNsense firewall security.

AVAILABLE TOOLS:
1. `query_telemetry`: Retrieves relational sensor readings from MySQL (vinereadings). Handles vineid mapping ('main unit' -> vineid 1), phase voltages (virv/viyv/vibv), currents (viri/viyi/vibi), energy, and time-series plotting.
2. `inspect_firewall_security`: Audits network ports (Port 69 TFTP, Port 3306 MySQL, Port 502 Modbus, Port 47808 BACnet, Port 3389 RDP) and simulates OPNsense REST API calls.
3. `diagnose_equipment_hazards`: Audits telemetry for equipment failure risks: thermal overheat (>60°C), current imbalance (>10%), voltage sags/surges (outside 210-250V), neutral faults (>15V), and low battery (<3.4V).
4. `manage_memory_and_rules`: Stores or lists user preferences in train_db. ONLY called if user explicitly says 'remember that...', 'save alias...', or asks for saved rules.

RULES:
- When user asks for data, readings, phase voltages, currents, temperatures, or plotting: CALL `query_telemetry`.
- When user asks about port safety, firewall rules, active states, or blocking ports: CALL `inspect_firewall_security`.
- When user asks about equipment health, failure prediction, hazards, or thermal alerts: CALL `diagnose_equipment_hazards`.
- For greetings or general conversation, reply directly without calling tools.
"""

class AgentExecutionResult:
    def __init__(
        self,
        answer: str,
        tool_calls: List[Dict[str, Any]],
        dataframes: List[pd.DataFrame] = None,
        raw_sql: str = "",
        should_plot: bool = False,
        metrics: List[str] = None
    ):
        self.answer = answer
        self.tool_calls = tool_calls
        self.dataframes = dataframes or []
        self.raw_sql = raw_sql
        self.should_plot = should_plot
        self.metrics = metrics or []


class BMSAgent:
    def __init__(
        self,
        model_name: str = "qwen2.5-coder:7b",
        host: str = "http://localhost:11434"
    ):
        self.model_name = model_name
        self.host = host
        self.client = ollama.Client(host=host)

    def load(self) -> BMSAgent:
        """Confirms Ollama reachability and checks model availability."""
        try:
            models = self.client.list()
            names = [m.get("model", m.get("name", "")) for m in models.get("models", [])]
        except Exception as e:
            raise RuntimeError(
                f"Could not reach Ollama server at {self.host}. Is Ollama running? (`ollama serve`)"
            ) from e

        if not any(self.model_name in n for n in names):
            raise RuntimeError(
                f"Model '{self.model_name}' not found in Ollama. Run: `ollama pull {self.model_name}`"
            )
        return self

    def run(
        self,
        prompt: str,
        history: Optional[List[Dict[str, str]]] = None,
        context: Optional[Dict[str, Any]] = None
    ) -> AgentExecutionResult:
        """
        Autonomous single-turn/two-turn optimized tool execution.
        Dispatches tools in native Python (<0.05s) and avoids redundant slow LLM hops.
        """
        context = context or {}
        executed_tool_calls: List[Dict[str, Any]] = []
        collected_dfs: List[pd.DataFrame] = []
        last_sql: str = ""
        should_plot = False
        metrics = []

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

        # 1. First Pass: Qwen 2.5 Coder inspects query and decides tool(s)
        try:
            response = self.client.chat(
                model=self.model_name,
                messages=messages,
                tools=TOOLS_SCHEMA,
                options={"temperature": 0.1, "num_predict": 400}
            )
        except Exception as e:
            return AgentExecutionResult(
                answer=f"⚠️ Connection error communicating with Ollama: {e}",
                tool_calls=[]
            )

        msg = response.get("message", {})
        content = msg.get("content", "").strip()
        tool_calls = msg.get("tool_calls") or []

        # If model did not call tools, return direct conversational answer (e.g. greeting)
        if not tool_calls:
            return AgentExecutionResult(
                answer=content or "Hello! I am ready to monitor your building telemetry and firewall security.",
                tool_calls=[]
            )

        # 2. Execute tools in native Python (Instant, < 0.05s)
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

            # Execute tool
            t_res = execute_tool(t_name, t_args, context=context)

            executed_tool_calls.append({
                "tool": t_name,
                "arguments": t_args,
                "result": t_res
            })

            # Capture telemetry artifacts
            if t_name == "query_telemetry":
                if "executed_sql" in t_res:
                    last_sql = t_res["executed_sql"]
                if "data" in t_res and isinstance(t_res["data"], list) and t_res["data"]:
                    df = pd.DataFrame(t_res["data"])
                    collected_dfs.append(df)
                if t_res.get("should_plot"):
                    should_plot = True

            elif t_name == "diagnose_equipment_hazards":
                if "latest_snapshot" in t_res:
                    # Provide snapshot df if available
                    snap = t_res.get("latest_snapshot", {})
                    if snap:
                        collected_dfs.append(pd.DataFrame([snap]))

            tool_responses.append({"tool": t_name, "result": t_res})

        # 3. Fast Synthesis of Result (Deterministic & Fast)
        final_answer = self._synthesize_fast_response(prompt, tool_responses)

        return AgentExecutionResult(
            answer=final_answer,
            tool_calls=executed_tool_calls,
            dataframes=collected_dfs,
            raw_sql=last_sql,
            should_plot=should_plot,
            metrics=metrics
        )

    def _synthesize_fast_response(self, prompt: str, tool_responses: List[Dict[str, Any]]) -> str:
        """
        Synthesizes a clean, direct, professional response combining tool outputs
        without running redundant multi-turn LLM inference loops that add 30s latency.
        """
        blocks = []

        for item in tool_responses:
            t_name = item["tool"]
            res = item["result"]

            if t_name == "inspect_firewall_security":
                rep = res.get("dryrun_report") or res.get("proposal_report", "")
                blocks.append(f"### 🛡️ OPNsense Firewall Inspection Result\n```text\n{rep}\n```")

            elif t_name == "diagnose_equipment_hazards":
                if res.get("status") == "success":
                    vid = res.get("vineid", 1)
                    score = res.get("health_score", 100)
                    status = res.get("overall_status", "OPTIMAL")
                    date = res.get("reading_date", "N/A")
                    time_val = res.get("reading_time", "N/A")
                    anomalies = res.get("anomalies", [])

                    badge = "🟢" if score >= 85 else ("🟡" if score >= 60 else "🔴")
                    diag_lines = [
                        f"### {badge} Equipment Health Diagnostic (Device vineid: {vid})",
                        f"**Health Score:** `{score}%` | **Status:** **{status}**",
                        f"*Evaluated Reading:* `{date} {time_val}`\n"
                    ]
                    if anomalies:
                        diag_lines.append("#### ⚠️ Detected Anomalies & Breaches:")
                        for a in anomalies:
                            diag_lines.append(f"- **[{a['severity']}] {a['hazard']}**: `{a['metric']}` (Threshold: `{a['threshold']}`) — *{a['impact']}*")
                    else:
                        diag_lines.append("✅ **All parameters normal**: Phase voltages within 210–250V, current imbalance <10%, and temperature <60°C.")

                    blocks.append("\n".join(diag_lines))
                else:
                    blocks.append(f"⚠️ {res.get('message', 'Hazard diagnostic could not complete.')}")

            elif t_name == "query_telemetry":
                if res.get("status") == "success":
                    rows = res.get("row_count", 0)
                    elapsed = res.get("time_taken", 0)
                    vid = res.get("vineid", 1)
                    sql = res.get("executed_sql", "")
                    
                    blocks.append(f"Here are the latest telemetry readings for **Device vineid {vid}** ({rows} records fetched in `{elapsed:.2f}s`):")
                elif res.get("status") == "validation_error":
                    blocks.append(f"⚠️ SQL Validation Failed: {res.get('message')}")
                elif res.get("status") == "execution_error":
                    blocks.append(f"⚠️ SQL Execution Error: {res.get('message')}")
                else:
                    blocks.append(f"⚠️ {res.get('message', 'Could not retrieve telemetry.')}")

            elif t_name == "manage_memory_and_rules":
                if res.get("status") == "success":
                    if "rules" in res:
                        r_lines = ["### 💾 Stored Persistent Rules in train_db:"]
                        for r in res.get("rules", []):
                            r_lines.append(f"- `[{r['category'].upper()}]` **{r['key']}**: {r['value']}")
                        blocks.append("\n".join(r_lines))
                    else:
                        blocks.append(f"💾 {res.get('message', 'Memory updated successfully.')}")
                else:
                    blocks.append(f"⚠️ Memory error: {res.get('message')}")

        return "\n\n".join(blocks) if blocks else "Autonomous inspection completed."
