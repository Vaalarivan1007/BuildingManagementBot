import json
import subprocess
import sys
import re

class MCPProcessClient:
    def __init__(self, script_name):
        self.script_name = script_name
        self.process = None

    def _ensure_process(self):
        if self.process is None or self.process.poll() is not None:
            self.process = subprocess.Popen(
                [sys.executable, "-u", self.script_name],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )

    def send_request(self, method, params=None, req_id=1):
        self._ensure_process()
        payload = {
            "jsonrpc": "2.0",
            "method": method,
            "params": params or {},
            "id": req_id
        }
        json_str = json.dumps(payload) + "\n"
        self.process.stdin.write(json_str)
        self.process.stdin.flush()
        response_line = self.process.stdout.readline()
        if response_line:
            return json.loads(response_line)
        return {}

    def close(self):
        if self.process and self.process.poll() is None:
            try:
                self.process.stdin.close()
                self.process.terminate()
                self.process.wait(timeout=2)
            except Exception:
                self.process.kill()

class AgentOrchestrator:
    def __init__(self):
        self.sec_client = MCPProcessClient("security_mcp_server.py")
        self.volt_client = MCPProcessClient("voltage_mcp_server.py")
        self.curr_client = MCPProcessClient("current_energy_mcp_server.py")

    def execute_combined_task(
        self,
        prompt,
        host="121.242.232.215",
        port=3306,
        user="intern01",
        db_password="Intern01@Rouser#2026",
        db_name="sunandjay"
    ):
        results = {}
        q_lower = prompt.lower()

        # Named protocol to port mapping for automatic recognition
        protocol_ports = {
            "tftp": 69,
            "modbus": 502,
            "bacnet": 47808,
            "rdp": 3389,
            "mysql": 3306,
            "telnet": 23,
            "ftp": 21,
            "ssh": 22,
            "snmp": 161,
            "mqtt": 1883,
            "redis": 6379,
            "smb": 445
        }

        # 1. Route to Security Agent (All Firewall & Port Commands)
        port_num = None
        port_matches = re.findall(r"\b(?:port\s*[:#]?\s*|is\s+port\s+)(\d{1,5})\b", q_lower)
        if not port_matches:
            port_matches = re.findall(r"\b(?:is\s+)?(\d{1,5})\s+(?:safe|secure|risky|open|vulnerable)\b", q_lower)

        if port_matches:
            port_num = int(port_matches[0])
        else:
            for proto, p_num in protocol_ports.items():
                if proto in q_lower and any(w in q_lower for w in ["safe", "port", "check", "block", "firewall", "risk"]):
                    port_num = p_num
                    break

        security_keywords = [
            "port", "firewall", "block", "allow", "security", "network", "rule", "rules",
            "state", "states", "connection", "connections", "service", "services",
            "gateway", "interface", "interfaces", "traffic", "bandwidth", "firmware",
            "tftp", "modbus", "bacnet", "rdp", "vulnerable", "risky"
        ]

        if port_num is not None:
            res = self.sec_client.send_request("tools/call", {
                "name": "check_port_risk",
                "arguments": {"port": port_num, "query": prompt}
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["security_agent"] = content
        elif any(k in q_lower for k in security_keywords):
            if any(k in q_lower for k in ["block", "propose", "deny", "drop", "allow"]):
                tool_name = "propose_firewall_rule"
            elif any(k in q_lower for k in ["state", "connections", "active connection"]):
                tool_name = "query_firewall_states"
            elif any(k in q_lower for k in ["rule", "rules", "policy"]):
                tool_name = "list_firewall_rules"
            elif any(k in q_lower for k in ["service", "services", "listening", "socket"]):
                tool_name = "audit_services"
            elif any(k in q_lower for k in ["matrix", "all ports"]):
                tool_name = "get_risk_matrix"
            else:
                tool_name = "inspect_network"

            res = self.sec_client.send_request("tools/call", {
                "name": tool_name,
                "arguments": {"query": prompt, "search": prompt}
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["security_agent"] = content

        # 2. Route to Voltage Agent
        if any(k in q_lower for k in ["voltage", "virv", "viyv", "vibv", "vinv", "phase voltage"]):
            res = self.volt_client.send_request("tools/call", {
                "name": "query_voltage_metrics",
                "arguments": {
                    "natural_prompt": telemetry_prompt or "Show latest phase voltages",
                    "host": host,
                    "port": port,
                    "user": user,
                    "password": db_password,
                    "database": db_name
                }
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["voltage_agent"] = content

        # 3. Route to Current & Thermal Agent
        if any(k in q_lower for k in ["current", "viri", "viyi", "vibi", "imbalance", "temp", "thermal", "energy"]):
            res = self.curr_client.send_request("tools/call", {
                "name": "query_current_energy",
                "arguments": {
                    "natural_prompt": telemetry_prompt or "Show latest current and thermal readings",
                    "host": host,
                    "port": port,
                    "user": user,
                    "password": db_password,
                    "database": db_name
                }
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["current_thermal_agent"] = content

        return json.dumps(results, indent=2)

    def execute_security_inspection(self, query: str) -> str:
        """Helper to run a security inspection directly through the security agent."""
        res_json = self.execute_combined_task(prompt=query)
        try:
            data = json.loads(res_json)
            return data.get("security_agent", res_json)
        except Exception:
            return res_json

    def close(self):
        self.sec_client.close()
        self.volt_client.close()
        self.curr_client.close()

def format_mcp_summary(raw_json_str: str) -> str:
    """Parses and formats the combined multi-agent MCP JSON response."""
    try:
        data = json.loads(raw_json_str)
    except Exception as e:
        return f"Error parsing MCP response: {e}"

    lines = ["\n=======================================================",
             "       🤖 MULTI-AGENT MCP EXECUTION DASHBOARD         ",
             "=======================================================\n"]

    # 1. Security Agent Summary
    if "security_agent" in data and data["security_agent"]:
        lines.append("🛡️ [NETWORK & FIREWALL SECURITY AGENT AUDIT]")
        lines.append(data["security_agent"])
        lines.append("")

    # 2. Voltage Agent Summary
    if "voltage_agent" in data and data["voltage_agent"]:
        lines.append("⚡ [VOLTAGE TELEMETRY AGENT]")
        try:
            volt_resp = json.loads(data["voltage_agent"])
            if volt_resp.get("status") == "success" and volt_resp.get("data"):
                record = volt_resp["data"][0]
                lines.append(f"   ├─ R-Phase Voltage (virv) : {record.get('virv')} V")
                lines.append(f"   ├─ Y-Phase Voltage (viyv) : {record.get('viyv')} V")
                lines.append(f"   ├─ B-Phase Voltage (vibv) : {record.get('vibv')} V")
                lines.append(f"   ├─ Neutral Voltage (vinv) : {record.get('vinv')} V")
                lines.append(f"   └─ Sensor Battery Voltage : {record.get('vibattery')}%")
            else:
                lines.append("   └─ Status: No voltage records returned.")
        except Exception:
            lines.append(f"   └─ Raw Output: {data['voltage_agent']}")
        lines.append("")

    # 3. Current & Thermal Agent Summary
    if "current_thermal_agent" in data and data["current_thermal_agent"]:
        lines.append("🌡️ [CURRENT & THERMAL TELEMETRY AGENT]")
        try:
            curr_resp = json.loads(data["current_thermal_agent"])
            if curr_resp.get("status") == "success" and curr_resp.get("data"):
                record = curr_resp["data"][0]
                lines.append(f"   ├─ R-Phase Current (viri) : {record.get('viri')} A")
                lines.append(f"   ├─ Y-Phase Current (viyi) : {record.get('viyi')} A")
                lines.append(f"   ├─ B-Phase Current (vibi) : {record.get('vibi')} A")
                lines.append(f"   ├─ Current Imbalance      : {record.get('vicurrentimbalance')}%")
                lines.append(f"   └─ Enclosure Temperature  : {record.get('vitemp')} °C")
            else:
                lines.append("   └─ Status: No current/thermal records returned.")
        except Exception:
            lines.append(f"   └─ Raw Output: {data['current_thermal_agent']}")
        lines.append("")

    lines.append("=======================================================")
    return "\n".join(lines)


if __name__ == "__main__":
    print("Initializing On-Demand MCP Orchestrator...")
    orchestrator = AgentOrchestrator()
    sample_prompt = "Check if port 3306 is risky, get latest phase voltages, and check current thermal readings."
    
    print("--- Sending Combined Multi-Agent Prompt to MCP Orchestrator ---")
    output = orchestrator.execute_combined_task(
        prompt=sample_prompt,
        host="121.242.232.215",
        port=3306,
        user="intern01",
        db_password="Intern01@Rouser#2026",
        db_name="sunandjay"
    )
    
    # Print formatted summary dashboard in terminal
    print(format_mcp_summary(output))
    orchestrator.close()