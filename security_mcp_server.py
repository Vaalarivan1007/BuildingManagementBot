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
            port_val = args.get("port", 0)
            res = opn.check_port_text(int(port_val))
        elif tool_name == "propose_firewall_rule":
            res = opn.propose_block(args.get("query", ""))
        else:
            res = "Unknown tool"

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