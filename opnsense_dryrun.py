"""
opn.py - OPNsense helper in ONE file.

DRY_RUN = True  (default): only prints the call it WOULD make. Sends nothing.
DRY_RUN = False: actually runs, but ONLY the read-only paths in LIVE_ALLOWED.

Use in your app:   from opn import handle
                   answer = handle("show open ports")

Test in terminal:  python opn.py

Put your key and secret in API_KEY and API_SECRET in the settings below.
(Environment variables OPNSENSE_KEY / OPNSENSE_SECRET also work as a fallback.)
"""

import os
import re

# ---------------- SETTINGS ----------------
HOST = "https://10.20.35.13"
DRY_RUN = True            # keep True until the key works, then set False
VERIFY_TLS = False        # False because the firewall likely has a self-signed cert

# PUT YOUR API KEY AND SECRET HERE (between the quotes).
# Never share this file, upload it, or commit it to git once these are filled in.
API_KEY = "IJm0H9L1D1kV7+Pcm/bMZeozlwrOzXvwF9jRWearmwdxcYl3DL/5dAsKZHN5XKG4HA50KXtk0vFFr4/2"
API_SECRET = "dS8STjGFjqzfSBwiSd05BJXIvcAy4X6VhBtVYhHgHwNz1RWBApVLsECnrQoQzhNZ0y8F0QcNas+cjUEV"
# ------------------------------------------

# (keywords, method, path, description)
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

# Only these can ever run for real. Add more only after checking the OPNsense API docs.
LIVE_ALLOWED = {"/api/core/firmware/status"}

# Queries containing these words are refused outright.
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
    import requests  # only needed when DRY_RUN is False

    key = API_KEY or os.environ.get("OPNSENSE_KEY", "")
    secret = API_SECRET or os.environ.get("OPNSENSE_SECRET", "")
    if not (key and secret):
        return "Fill in API_KEY and API_SECRET at the top of opn.py first."
    try:
        r = requests.get(HOST + path, auth=(key, secret), timeout=10, verify=VERIFY_TLS)
        r.raise_for_status()
        return r.json()
    except Exception as e:  # show the problem, never crash the app
        return "Request failed: " + str(e)


def handle(query):
    """Main entry point. Returns text you can show in your chatbot."""
    p = plan(query)
    if p["status"] != "OK":
        return "[{}] {}".format(p["status"], p["reason"])

    call = "{} {}{}".format(p["method"], HOST, p["path"])

    if DRY_RUN:
        return "[DRY RUN - NOT EXECUTED]\nWould run: {}\nPurpose: {}".format(call, p["description"])

    if p["method"] != "GET" or p["path"] not in LIVE_ALLOWED:
        return "[BLOCKED] Not enabled for live use yet.\nWould run: {}".format(call)

    return "[LIVE]\nRan: {}\nResult: {}".format(call, _run_live(p["path"]))


if __name__ == "__main__":
    print("OPNsense bot - {}. Type 'quit' to exit.\n".format(
        "DRY RUN (nothing executed)" if DRY_RUN else "LIVE (read-only)"))
    while True:
        try:
            text = input("You> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if text.lower() in ("quit", "exit"):
            break
        if text:
            print(handle(text), "\n")