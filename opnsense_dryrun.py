"""
opnsense_dryrun.py - OPNsense Security Helper & Dry-Run Auditor
"""

import os
import re

# ---------------- SETTINGS ----------------
HOST = "https://10.20.35.13"
DRY_RUN = True            # Keep True for dry-run simulation
VERIFY_TLS = False

API_KEY = "IJm0H9L1D1kV7+Pcm/bMZeozlwrOzXvwF9jRWearmwdxcYl3DL/5dAsKZHN5XKG4HA50KXtk0vFFr4/2"
API_SECRET = "dS8STjGFjqzfSBwiSd05BJXIvcAy4X6VhBtVYhHgHwNz1RWBApVLsECnrQoQzhNZ0y8F0QcNas+cjUEV"
# ------------------------------------------

PORT_RISK = {
    21: "HIGH RISK - Cleartext FTP File Transfer",
    22: "HIGH RISK - SSH Remote Terminal Shell",
    23: "CRITICAL RISK - Cleartext Telnet Access",
    25: "MODERATE RISK - SMTP Mail Transmission",
    53: "LOW RISK - DNS Name Resolution Service",
    80: "LOW RISK - Unencrypted HTTP Web Server",
    443: "SAFE - Encrypted HTTPS Web Server",
    3306: "MODERATE RISK - MySQL Database Port. Direct external access should be restricted via OPNsense firewall rules.",
    3389: "HIGH RISK - Windows Remote Desktop Protocol (RDP)",
    8080: "MODERATE RISK - Alternative HTTP Web Proxy Service"
}

COMMANDS = [
    (["firewall rule", "rules", "allowed port", "blocked port", "open port", "closed port"],
     "GET", "/api/firewall/filter/search_rule",
     "List firewall rules (which ports are allowed/blocked)"),
    (["listening", "socket", "service"],
     "POST", "/api/core/service/search",
     "List services and whether they are running"),
    (["state", "connection", "active"],
     "POST", "/api/diagnostics/firewall/query_states",
     "List active connections"),
    (["interface", "ip address", "network"],
     "GET", "/api/diagnostics/interface/get_interface_config",
     "Show interface configuration"),
    (["traffic", "bandwidth"],
     "GET", "/api/diagnostics/traffic/interface",
     "Show traffic per interface"),
    (["version", "firmware", "update"],
     "GET", "/api/core/firmware/status",
     "Show firmware / version status"),
    (["gateway", "wan", "uptime"],
     "GET", "/api/routes/gateway/status",
     "Show gateway / WAN health"),
]

LIVE_ALLOWED = {"/api/core/firmware/status"}

BLOCKED_WORDS = {
    "add", "set", "del", "delete", "apply", "toggle", "reboot", "halt",
    "poweroff", "upgrade", "reconfigure", "restart", "stop", "start",
    "flush", "kill", "revert", "import", "reset", "disable", "enable",
}

def plan(query):
    """Decide which call matches the query. Never sends anything."""
    words = set(re.findall(r"[a-z]+", query.lower()))
    if words & BLOCKED_WORDS:
        return {"status": "REFUSED", "reason": "This bot is read-only."}

    q = query.lower()
    for keywords, method, path, desc in COMMANDS:
        if any(k in q for k in keywords):
            return {"status": "OK", "method": method, "path": path, "description": desc}
    return {"status": "NO_MATCH", "reason": "No read-only command matches that query."}

def _run_live(path):
    import requests
    key = API_KEY or os.environ.get("OPNSENSE_KEY", "")
    secret = API_SECRET or os.environ.get("OPNSENSE_SECRET", "")
    if not (key and secret):
        return "Fill in API_KEY and API_SECRET at the top of opn.py first."
    try:
        r = requests.get(HOST + path, auth=(key, secret), timeout=10, verify=VERIFY_TLS)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        return "Request failed: " + str(e)

def handle(query):
    """Main entry point for general network inspection."""
    p = plan(query)
    if p["status"] != "OK":
        return "[{}] {}".format(p["status"], p["reason"])

    call = "{} {}{}".format(p["method"], HOST, p["path"])

    if DRY_RUN:
        return "[DRY RUN - NOT EXECUTED]\nWould run: {}\nPurpose: {}".format(call, p["description"])

    if p["method"] != "GET" or p["path"] not in LIVE_ALLOWED:
        return "[BLOCKED] Not enabled for live use yet.\nWould run: {}".format(call)

    return "[LIVE]\nRan: {}\nResult: {}".format(call, _run_live(p["path"]))

def check_port_text(port: int) -> str:
    """Evaluate specific port risk status."""
    p = int(port)
    if p in PORT_RISK:
        return f"Port {p}: {PORT_RISK[p]}"
    return f"Port {p}: Standard unclassified port. Audit active socket state via OPNsense firewall."

def propose_block(query: str) -> str:
    """Generate a safe, dry-run proposal for blocking network traffic."""
    return f"[DRY RUN PROPOSAL]\nProposed Firewall Action: BLOCK\nTarget Query: {query}\nStatus: Rule simulated. No changes applied to live OPNsense firewall."

if __name__ == "__main__":
    print("OPNsense bot active. Type 'quit' to exit.\n")
    while True:
        try:
            text = input("You> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if text.lower() in ("quit", "exit"):
            break
        if text:
            print(handle(text), "\n")