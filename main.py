"""
opn.py - OPNsense helper in ONE file.

DRY_RUN = True  (default): only prints the call it WOULD make. Sends nothing.
DRY_RUN = False: actually runs, but ONLY the read-only paths in LIVE_ALLOWED.

WRITE REQUESTS (e.g. "block facebook", "block port 3389") ONLY SHOW A PROPOSAL.
There is no code in this file that sends a write call. Nothing is ever changed.

Use in your app:   from opn import handle
                   answer = handle("show open ports")

Test in terminal:  python opn.py

Put your key and secret in API_KEY and API_SECRET in the settings below.
(Environment variables OPNSENSE_KEY / OPNSENSE_SECRET also work as a fallback.)
"""

import json
import os
import re

# ---------------- SETTINGS ----------------
HOST = "https://10.20.35.13"
DRY_RUN = True            # keep True until the key works, then set False
VERIFY_TLS = False        # False because the firewall likely has a self-signed cert

# PUT YOUR API KEY AND SECRET HERE (between the quotes).
# Never share this file, upload it, or commit it to git once these are filled in.
API_KEY = ""
API_SECRET = ""
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



# ---------------- WRITE PROPOSALS (never executed) ----------------
SITES = {
    "facebook": ["facebook.com", "fb.com", "fbcdn.net", "messenger.com"],
    "instagram": ["instagram.com", "cdninstagram.com"],
    "youtube": ["youtube.com", "youtu.be", "googlevideo.com"],
    "twitter": ["twitter.com", "x.com", "twimg.com"],
    "tiktok": ["tiktok.com", "tiktokcdn.com"],
}

# Ports the bot will never propose blocking (web, DNS, firewall admin access).
PROTECTED_PORTS = {22, 53, 80, 443}

RISKY_PORTS = {
    21: "FTP", 23: "Telnet", 69: "TFTP", 135: "Windows RPC", 139: "NetBIOS",
    445: "SMB", 3389: "RDP", 5900: "VNC", 161: "SNMP", 1433: "MSSQL",
    3306: "MySQL", 5432: "PostgreSQL", 6379: "Redis", 27017: "MongoDB",
    9200: "Elasticsearch",
}


def _steps_text(steps):
    out = []
    for i, (method, path, body) in enumerate(steps, 1):
        out.append("  {}. {} {}{}".format(i, method, HOST, path))
        if body:
            for line in json.dumps(body, indent=2).splitlines():
                out.append("       " + line)
    return "\n".join(out)


def propose_block(query):
    """Build the calls that WOULD block a site or port. Returns text only."""
    q = query.lower().strip()
    port_match = re.search(r"\bports?\s+(\d{1,5})\b", q)

    savepoint = ("POST", "/api/firewall/filter/savepoint", None)
    apply_ = ("POST", "/api/firewall/filter/apply/<REVISION_FROM_STEP_1>", None)
    confirm = ("POST", "/api/firewall/filter/cancelRollback/<REVISION_FROM_STEP_1>", None)

    if port_match:
        port = int(port_match.group(1))
        if port in PROTECTED_PORTS:
            return ("[REFUSED] Port {} is protected (web / DNS / firewall access). "
                    "Blocking it could lock you out or break the network.".format(port))
        note = ""
        if port == 3306:
            note = ("\nWARNING: 3306 is MySQL. Your BMS app uses it. Only block it "
                    "on the WAN side, never internally.")
        label = RISKY_PORTS.get(port, "custom port")
        rule = {"rule": {
            "enabled": "1", "action": "block", "interface": "wan",
            "direction": "in", "ipprotocol": "inet", "protocol": "TCP",
            "source_net": "any", "destination_net": "any",
            "destination_port": str(port),
            "description": "Block {} ({}) from internet - bot proposal".format(port, label),
        }}
        steps = [savepoint, ("POST", "/api/firewall/filter/add_rule", rule), apply_, confirm]
        title = "Block inbound TCP port {} ({}) on WAN".format(port, label)
    else:
        target = re.sub(r"^\s*block\s+(the\s+)?", "", q)
        target = re.sub(r"\s+(website|site|access)$", "", target).strip()
        if target in SITES:
            domains = SITES[target]
        elif re.match(r"^[a-z0-9.-]+\.[a-z]{2,}$", target):
            domains = [target]
        else:
            return "[NO_MATCH] Say e.g. 'block facebook', 'block example.com' or 'block port 3389'."
        name = "Block_" + re.sub(r"[^a-z0-9]", "_", target)
        alias = {"alias": {
            "enabled": "1", "name": name, "type": "host",
            "content": "\n".join(domains),
            "description": "Domains for {} (bot proposal)".format(target),
        }}
        rule = {"rule": {
            "enabled": "1", "action": "block", "interface": "lan",
            "direction": "in", "ipprotocol": "inet", "protocol": "any",
            "source_net": "any", "destination_net": name,
            "description": "Block {} - bot proposal".format(target),
        }}
        steps = [
            savepoint,
            ("POST", "/api/firewall/alias/add_item", alias),
            ("POST", "/api/firewall/alias/reconfigure", None),
            ("POST", "/api/firewall/filter/add_rule", rule),
            apply_,
            confirm,
        ]
        title = "Block {} for LAN users ({})".format(target, ", ".join(domains))
        note = ("\nNOTE: the rule must sit ABOVE any 'allow all' rule to take effect. "
                "Interface name ('lan') and API paths must be checked for your OPNsense version.")

    return ("[PROPOSAL - NOT EXECUTED]\n{}\nCalls it WOULD make, in order "
            "(step 1 gives an auto-rollback safety net):\n{}{}\n\n"
            "Nothing was sent to the firewall.").format(title, _steps_text(steps), note)



# ---------------- KNOWLEDGE: risky ports (static info, no firewall call) ----------------
PORT_INFO = [
    (21, "FTP", "Unencrypted logins and files"),
    (23, "Telnet", "Unencrypted remote access, very weak"),
    (69, "TFTP", "No authentication"),
    (135, "Windows RPC", "Common attack target"),
    (139, "NetBIOS", "Leaks info, old Windows file sharing"),
    (445, "SMB", "Ransomware and worm target (e.g. WannaCry)"),
    (3389, "RDP", "Constant brute-force attacks"),
    (5900, "VNC", "Often weak or no password"),
    (161, "SNMP", "Leaks network info with default community strings"),
    (1433, "MSSQL", "Database, should never face the internet"),
    (3306, "MySQL", "Database, should never face the internet (your BMS uses it internally)"),
    (5432, "PostgreSQL", "Database, should never face the internet"),
    (6379, "Redis", "Often has no password"),
    (27017, "MongoDB", "Often has no password"),
    (9200, "Elasticsearch", "Often has no password"),
    (22, "SSH", "Fine if hardened; risky with password login exposed to the internet"),
    (80, "HTTP", "Unencrypted web traffic"),
]


def vulnerable_ports_text():
    lines = ["Commonly risky ports (a risk mainly when reachable from the INTERNET):", ""]
    for port, name, why in PORT_INFO:
        lines.append("  {:>5}  {:<14} {}".format(port, name, why))
    lines.append("")
    lines.append("A port is only a problem if a service is listening AND the firewall exposes it.")
    lines.append("Try: 'block port 3389' to see the rule that would close one (proposal only).")
    return "\n".join(lines)



# Common ports that are normally fine when the service is kept updated.
COMMON_OK = {
    25: ("SMTP", "Mail sending. Fine on a mail server; open relays get abused."),
    53: ("DNS", "Name lookups. Don't expose to the internet unless you run a public DNS server."),
    67: ("DHCP", "Address assignment. Internal use only."),
    110: ("POP3", "Mail retrieval, unencrypted. Prefer 995."),
    123: ("NTP", "Time sync. Fine, keep it updated."),
    143: ("IMAP", "Mail retrieval, unencrypted. Prefer 993."),
    443: ("HTTPS", "Encrypted web traffic. Normal, safe if the web app is patched."),
    465: ("SMTPS", "Encrypted mail sending."),
    587: ("SMTP submission", "Mail sending with login, normally encrypted."),
    993: ("IMAPS", "Encrypted mail retrieval."),
    995: ("POP3S", "Encrypted mail retrieval."),
    1194: ("OpenVPN", "VPN. Fine with strong auth."),
    4500: ("IPsec NAT-T", "VPN. Fine with strong auth."),
    500: ("IPsec IKE", "VPN. Fine with strong auth."),
    51820: ("WireGuard", "VPN. Fine, very small attack surface."),
    8080: ("HTTP alt", "Often a web app or admin panel. Check what is behind it."),
    8443: ("HTTPS alt", "Often a web app or admin panel. Check what is behind it."),
}
CONDITIONAL_PORTS = {22, 80}


def check_port_text(port):
    """Say whether one port is considered risky. Static knowledge, no firewall call."""
    if not 1 <= port <= 65535:
        return "[NO_MATCH] Port numbers go from 1 to 65535."

    info = {p_: (n, w) for p_, n, w in PORT_INFO}
    if port in info and port not in CONDITIONAL_PORTS:
        name, why = info[port]
        verdict = "HIGH RISK if reachable from the internet"
    elif port in CONDITIONAL_PORTS:
        name, why = info[port]
        verdict = "CONDITIONAL (depends on how it is configured)"
    elif port in COMMON_OK:
        name, why = COMMON_OK[port]
        verdict = "GENERALLY OK"
    else:
        return ("Port {}: UNKNOWN. It is not a well-known port, so I can't judge it "
                "from the number alone.\nWhat matters is what service listens on it "
                "and whether it is exposed to the internet.").format(port)

    text = ("Port {} ({})\nVerdict: {}\nWhy: {}\n\n"
            "Note: a port number alone doesn't prove a vulnerability. Risk depends on the "
            "service behind it, its version, and whether the firewall exposes it."
            ).format(port, name, verdict, why)
    if port not in PROTECTED_PORTS:
        text += "\nTry: 'block port {}' to see the rule that would close it (proposal only).".format(port)
    return text


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
    ql = query.lower()

    if re.match(r"^\s*block\b", ql):
        return propose_block(query)  # proposal text only, never executed

    risk_words = r"vulner|vulnar|risky|risk|dangerous|insecure|unsafe|safe|secure|exploit|threat"
    num = re.search(r"\b(\d{1,5})\b", ql)
    if num and re.search(risk_words, ql):
        return check_port_text(int(num.group(1)))

    if re.search(r"vulner|vulnar|risky port|dangerous port|insecure port|unsafe port", ql):
        return vulnerable_ports_text()

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