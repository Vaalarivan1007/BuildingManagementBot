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
                    {"name": "inspect_network", "description": "Inspect network firewall status"},
                    {"name": "check_port_risk", "description": "Check port vulnerability"},
                    {"name": "propose_firewall_rule", "description": "Propose dry-run firewall rule"}
                ]
            }
        }
    elif method == "tools/call":
        tool_name = params.get("name")
        args = params.get("arguments", {})
        
        if tool_name == "inspect_network":
            res = opn.handle(args.get("query", ""))
        elif tool_name == "check_port_risk":
            res = opn.check_port_text(int(args.get("port", 0)))
        elif tool_name == "propose_firewall_rule":
            res = opn.propose_block(args.get("query", ""))
        else:
            res = "Unknown tool"

        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {"content": [{"type": "text", "text": str(res)}]}
        }

if __name__ == "__main__":
    for line in sys.stdin:
        if not line.strip():
            continue
        try:
            req = json.loads(line)
            resp = handle_request(req)
            sys.stdout.write(json.dumps(resp) + "\n")
            sys.stdout.flush()
        except Exception as e:
            sys.stderr.write(f"Error: {e}\n")