"""
security_mcp_server.py - OPNsense Firewall & Network Security MCP Agent
"""

import sys
import json
import opnsense_dryrun as opn

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
                    {
                        "name": "check_port_risk",
                        "description": "Evaluate port safety and generate detailed OPNsense dry-run API queries (e.g. is port 69 safe)"
                    },
                    {
                        "name": "inspect_network",
                        "description": "Execute general OPNsense firewall inspections, commands, and audits"
                    },
                    {
                        "name": "propose_firewall_rule",
                        "description": "Generate simulated dry-run OPNsense firewall rules to block or allow traffic"
                    },
                    {
                        "name": "query_firewall_states",
                        "description": "Audit pf state table active connections and sessions"
                    },
                    {
                        "name": "list_firewall_rules",
                        "description": "Inspect active firewall filter rules across WAN, LAN, and floating rules"
                    },
                    {
                        "name": "audit_services",
                        "description": "Audit listening daemons, socket services, and firewall processes"
                    },
                    {
                        "name": "get_risk_matrix",
                        "description": "Retrieve comprehensive Building Management System port risk matrix"
                    }
                ]
            }
        }
    elif method == "tools/call":
        tool_name = params.get("name")
        args = params.get("arguments", {})
        
        try:
            if tool_name in ["check_port_risk", "inspect_port_safety"]:
                port_val = args.get("port")
                query_val = args.get("query", "")
                if port_val is not None:
                    res = opn.inspect_port_detailed_dryrun(int(port_val), query_val)
                elif query_val:
                    res = opn.handle(query_val)
                else:
                    res = opn.handle("check port 69")

            elif tool_name == "inspect_network":
                query_text = args.get("query", "")
                res = opn.handle(query_text)

            elif tool_name == "propose_firewall_rule":
                query_text = args.get("query", "")
                res = opn.propose_block(query_text)

            elif tool_name == "query_firewall_states":
                search_term = args.get("search", "")
                res = opn.handle(f"state connection {search_term}".strip())

            elif tool_name == "list_firewall_rules":
                search_term = args.get("search", "")
                res = opn.handle(f"firewall rules {search_term}".strip())

            elif tool_name == "audit_services":
                search_term = args.get("search", "")
                res = opn.handle(f"listening services {search_term}".strip())

            elif tool_name == "get_risk_matrix":
                res = opn.vulnerable_ports_text()

            else:
                # Universal fallback: attempt to handle query with opn.handle
                query_text = args.get("query") or args.get("prompt") or str(args)
                res = opn.handle(query_text)

        except Exception as e:
            res = f"[SECURITY AGENT ERROR] {e}"

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