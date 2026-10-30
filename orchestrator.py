import json
import subprocess
import sys
import re

class MCPProcessClient:
    def __init__(self, script_name):
        self.process = subprocess.Popen(
            [sys.executable, script_name],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

    def send_request(self, method, params=None, req_id=1):
        payload = {
            "jsonrpc": "2.0",
            "method": method,
            "params": params or {},
            "id": req_id
        }
        self.process.stdin.write(json.dumps(payload) + "\n")
        self.process.stdin.flush()
        response_line = self.process.stdout.readline()
        if response_line:
            return json.loads(response_line)
        return {}

    def close(self):
        self.process.terminate()

class AgentOrchestrator:
    def __init__(self):
        self.sec_client = MCPProcessClient("security_mcp_server.py")
        self.tel_client = MCPProcessClient("telemetry_mcp_server.py")

    def execute_combined_task(self, prompt, db_password="", db_name="telemetry_db"):
        results = {}
        q_lower = prompt.lower()

        # 1. Route to Security Agent
        port_match = re.search(r"\b(\d{1,5})\b", q_lower)
        if port_match and any(w in q_lower for w in ["risky", "vulnerable", "safe", "risk"]):
            port_num = int(port_match.group(1))
            res = self.sec_client.send_request("tools/call", {
                "name": "check_port_risk",
                "arguments": {"port": port_num}
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["security_agent"] = content
        elif any(k in q_lower for k in ["port", "firewall", "block", "security", "network"]):
            res = self.sec_client.send_request("tools/call", {
                "name": "inspect_network",
                "arguments": {"query": prompt}
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["security_agent"] = content

        # 2. Route to Telemetry Agent
        if any(k in q_lower for k in ["telemetry", "voltage", "current", "reading", "energy", "temp"]):
            res = self.tel_client.send_request("tools/call", {
                "name": "query_telemetry",
                "arguments": {
                    "natural_prompt": prompt,
                    "host": "localhost",
                    "port": 3306,
                    "user": "root",
                    "password": db_password,
                    "database": db_name
                }
            })
            content = res.get("result", {}).get("content", [{}])[0].get("text", "")
            results["telemetry_agent"] = content

        return json.dumps(results, indent=2)

    def close(self):
        self.sec_client.close()
        self.tel_client.close()

if __name__ == "__main__":
    orchestrator = AgentOrchestrator()
    sample_prompt = "Check if port 3306 is risky and get the latest telemetry voltage readings."
    
    # Pass your MySQL password and database name here
    output = orchestrator.execute_combined_task(
        prompt=sample_prompt,
        db_password="YOUR_MYSQL_PASSWORD_HERE",
        db_name="YOUR_DATABASE_NAME"
    )
    
    print("--- Sending Combined Prompt to MCP Orchestrator ---")
    print(output)
    orchestrator.close()