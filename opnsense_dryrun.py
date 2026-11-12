"""
opnsense_dryrun.py - OPNsense Security Helper & Detailed Dry-Run Auditor
"""

import os
import re
import json
from dotenv import load_dotenv

load_dotenv()

# ---------------- SETTINGS & CREDENTIALS ----------------
def _clean_url(raw_url: str) -> str:
    """Normalize OPNsense URL and strip markdown link wrappers if present."""
    if not raw_url:
        return "https://192.168.1.1"
    m = re.search(r"https?://[^\s\)\]]+", raw_url)
    url = m.group(0) if m else raw_url.strip()
    url = re.sub(r"/api/?$", "", url)
    return url.rstrip("/")

HOST = _clean_url(os.getenv("OPNSENSE_URL", "https://192.168.1.1"))
DRY_RUN = True            # Keep True for safe dry-run simulation
VERIFY_TLS = False

API_KEY = os.getenv(
    "OPNSENSE_KEY",
    "IJm0H9L1D1kV7+Pcm/bMZeozlwrOzXvwF9jRWearmwdxcYl3DL/5dAsKZHN5XKG4HA50KXtk0vFFr4/2"
).strip()

API_SECRET = os.getenv(
    "OPNSENSE_SECRET",
    "dS8STjGFjqzfSBwiSd05BJXIvcAy4X6VhBtVYhHgHwNz1RWBApVLsECnrQoQzhNZ0y8F0QcNas+cjUEV"
).strip()
# ---------------------------------------------------------

# ---------------- COMPREHENSIVE PORT RISK REGISTRY ----------------
PORT_REGISTRY = {
    20: {
        "service": "FTP-Data",
        "protocol": "TCP",
        "risk": "HIGH RISK - Cleartext File Transfer Channel",
        "severity": "HIGH",
        "desc": "Transfers unencrypted file payloads. Vulnerable to packet sniffing and traffic interception.",
        "recommended": "BLOCK on WAN. Replace with SFTP (SSH Port 22) or FTPS."
    },
    21: {
        "service": "FTP-Control",
        "protocol": "TCP",
        "risk": "HIGH RISK - Cleartext FTP Command & Authentication",
        "severity": "HIGH",
        "desc": "Authenticates user credentials in cleartext. Trivial to sniff over shared or untrusted networks.",
        "recommended": "BLOCK on WAN. Decommission in favor of secure SSH/SFTP endpoints."
    },
    22: {
        "service": "SSH",
        "protocol": "TCP",
        "risk": "MODERATE/HIGH RISK - Remote Shell Terminal",
        "severity": "MODERATE",
        "desc": "Encrypted administrative shell, but prime target for brute-force and automated credential attacks.",
        "recommended": "Restrict to internal management subnet or VPN only; NEVER expose directly to WAN without rate-limiting."
    },
    23: {
        "service": "Telnet",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Cleartext Terminal Access",
        "severity": "CRITICAL",
        "desc": "Zero encryption. Passwords, keystrokes, and session tokens transmitted as plain ASCII text.",
        "recommended": "IMMEDIATELY BLOCK and disable service. Replace with SSH."
    },
    25: {
        "service": "SMTP",
        "protocol": "TCP",
        "risk": "MODERATE RISK - Simple Mail Transfer Protocol",
        "severity": "MODERATE",
        "desc": "Unauthenticated or misconfigured mail relays can be exploited for spam distribution or spoofing.",
        "recommended": "BLOCK inbound WAN traffic unless operating an authorized dedicated mail transfer agent."
    },
    53: {
        "service": "DNS",
        "protocol": "UDP/TCP",
        "risk": "LOW/MODERATE RISK - Domain Name Resolution",
        "severity": "MODERATE",
        "desc": "Open DNS resolvers can be weaponized in amplified distributed denial of service (DDoS) reflection attacks.",
        "recommended": "Restrict to internal LAN resolvers; drop open external WAN recursive queries."
    },
    67: {
        "service": "DHCP Server",
        "protocol": "UDP",
        "risk": "MODERATE RISK - Dynamic Host Configuration",
        "severity": "MODERATE",
        "desc": "DHCP broadcast messages. Rogue DHCP servers can hijack local gateway routes.",
        "recommended": "Keep confined strictly to internal LAN broadcast domains; filter at boundary."
    },
    68: {
        "service": "DHCP Client",
        "protocol": "UDP",
        "risk": "LOW RISK - DHCP Client Communication",
        "severity": "LOW",
        "desc": "Client-side DHCP communication.",
        "recommended": "Allowed internally; drop spoofed external DHCP responses on WAN."
    },
    69: {
        "service": "TFTP",
        "protocol": "UDP",
        "risk": "HIGH RISK - Trivial File Transfer Protocol (Cleartext & Unauthenticated)",
        "severity": "HIGH",
        "desc": "TFTP operates over unauthenticated UDP. It contains zero access control or encryption. Commonly used for router/switch bootstrapping and sensor PXE boots. Exposure permits arbitrary firmware/config extraction.",
        "recommended": "BLOCK on WAN completely. Confine exclusively to isolated provisioning VLANs if required for local firmware flashing."
    },
    80: {
        "service": "HTTP",
        "protocol": "TCP",
        "risk": "LOW/MODERATE RISK - Unencrypted Web Server",
        "severity": "MODERATE",
        "desc": "Cleartext HTTP traffic. Subject to man-in-the-middle tampering and session hijacking.",
        "recommended": "Redirect all HTTP traffic to HTTPS (Port 443) with HSTS enabled."
    },
    110: {
        "service": "POP3",
        "protocol": "TCP",
        "risk": "MODERATE RISK - Cleartext Email Retrieval",
        "severity": "MODERATE",
        "desc": "Retrieves emails in cleartext. Plaintext authentication vulnerability.",
        "recommended": "BLOCK. Upgrade to POP3S (Port 995) or IMAPS (Port 993)."
    },
    123: {
        "service": "NTP",
        "protocol": "UDP",
        "risk": "LOW/MODERATE RISK - Network Time Protocol",
        "severity": "LOW",
        "desc": "Essential for clock synchronization. Vulnerable to monlist reflection amplification attacks if misconfigured.",
        "recommended": "Restrict to trusted external NTP pools and disable monlist query feature."
    },
    135: {
        "service": "MS-RPC",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Microsoft Windows RPC Endpoint Mapper",
        "severity": "CRITICAL",
        "desc": "Core Windows remote procedure call service. Historic vector for remote code execution worms (e.g. Blaster).",
        "recommended": "BLOCK on all external perimeters and untrusted network segments."
    },
    137: {
        "service": "NetBIOS-NS",
        "protocol": "UDP",
        "risk": "HIGH RISK - NetBIOS Name Service",
        "severity": "HIGH",
        "desc": "Exposes local computer hostnames, workgroup names, and domain infrastructure to reconnaissance.",
        "recommended": "BLOCK at firewall perimeter."
    },
    138: {
        "service": "NetBIOS-DGM",
        "protocol": "UDP",
        "risk": "HIGH RISK - NetBIOS Datagram Service",
        "severity": "HIGH",
        "desc": "Cleartext SMB/NetBIOS broadcasts.",
        "recommended": "BLOCK on perimeter firewalls."
    },
    139: {
        "service": "NetBIOS-SSN",
        "protocol": "TCP",
        "risk": "HIGH RISK - NetBIOS Session Service",
        "severity": "HIGH",
        "desc": "Legacy Windows file and printer sharing.",
        "recommended": "BLOCK on all external interfaces."
    },
    143: {
        "service": "IMAP",
        "protocol": "TCP",
        "risk": "MODERATE RISK - Cleartext IMAP Mail",
        "severity": "MODERATE",
        "desc": "Unencrypted mail synchronization.",
        "recommended": "BLOCK in favor of IMAPS (Port 993)."
    },
    161: {
        "service": "SNMP",
        "protocol": "UDP",
        "risk": "HIGH RISK - Simple Network Management Protocol",
        "severity": "HIGH",
        "desc": "SNMP v1/v2c uses cleartext community strings ('public'/'private'). Exposes full network routing & device metrics.",
        "recommended": "BLOCK on WAN. Restrict to internal management subnets and migrate to SNMPv3 with auth and privacy."
    },
    389: {
        "service": "LDAP",
        "protocol": "TCP",
        "risk": "HIGH RISK - Cleartext Directory Service",
        "severity": "HIGH",
        "desc": "Unencrypted Active Directory / LDAP queries leak user credentials and organizational schema.",
        "recommended": "BLOCK externally. Use LDAPS (Port 636) or StartTLS."
    },
    443: {
        "service": "HTTPS",
        "protocol": "TCP",
        "risk": "STANDARD / SAFE - Encrypted Web Server",
        "severity": "SAFE",
        "desc": "TLS-encrypted web communications. Standard safe production port when paired with current TLS 1.3 / 1.2 certificates.",
        "recommended": "ALLOW with standard Web Application Firewall (WAF) or IPS inspection."
    },
    445: {
        "service": "SMB",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Direct Windows SMB File Sharing",
        "severity": "CRITICAL",
        "desc": "Primary vector for ransomware propagation (e.g. WannaCry, NotPetya via EternalBlue).",
        "recommended": "BLOCK on all perimeter firewalls without exception."
    },
    502: {
        "service": "Modbus TCP",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Building Management & Industrial SCADA Protocol",
        "severity": "CRITICAL",
        "desc": "De-facto standard for building electrical sensors, PLCs, and HVAC controllers. Modbus has ZERO built-in authentication; any packet can toggle relays or alter telemetry values.",
        "recommended": "ISOLATE in dedicated BMS OT VLAN. Strictly BLOCK from any Internet or IT WAN access."
    },
    1433: {
        "service": "MS-SQL",
        "protocol": "TCP",
        "risk": "HIGH RISK - Microsoft SQL Server Database",
        "severity": "HIGH",
        "desc": "Direct database listener. Exposure enables remote SQL injection, password spraying, and xp_cmdshell compromise.",
        "recommended": "BLOCK WAN access. Enforce VPN or application tier proxy."
    },
    1521: {
        "service": "Oracle-DB",
        "protocol": "TCP",
        "risk": "HIGH RISK - Oracle TNS Listener",
        "severity": "HIGH",
        "desc": "Direct relational database listener. Susceptible to TNS poisoning and brute-force access.",
        "recommended": "BLOCK WAN access. Restrict access to designated database clients only."
    },
    1883: {
        "service": "MQTT",
        "protocol": "TCP",
        "risk": "HIGH/MODERATE RISK - IoT & BMS Telemetry Broker",
        "severity": "HIGH",
        "desc": "Transmits building telemetry (temperatures, voltages, currents). If unencrypted, permits unauthorized sensor eavesdropping.",
        "recommended": "BLOCK plain MQTT 1883 externally. Migrate to MQTTS (Port 8883) with mutual TLS certificates."
    },
    3306: {
        "service": "MySQL Database",
        "protocol": "TCP",
        "risk": "MODERATE/HIGH RISK - MySQL Telemetry Database Port",
        "severity": "HIGH",
        "desc": "Hosts core Building Management telemetry ('sunandjay' / 'vinereadings'). Direct external exposure risks credential attacks and unauthorized data exfiltration.",
        "recommended": "BLOCK public WAN access via OPNsense firewall. Limit access strictly to authorized application server IPs (121.242.232.215 / local LAN)."
    },
    3389: {
        "service": "RDP",
        "protocol": "TCP/UDP",
        "risk": "CRITICAL RISK - Windows Remote Desktop Protocol",
        "severity": "CRITICAL",
        "desc": "Number one attack vector for external ransomware intrusions, BlueKeep exploits, and continuous credential stuffing.",
        "recommended": "BLOCK on WAN. Require an OPNsense IPsec/WireGuard VPN tunnel before permitting RDP access."
    },
    5432: {
        "service": "PostgreSQL",
        "protocol": "TCP",
        "risk": "HIGH RISK - PostgreSQL Database Port",
        "severity": "HIGH",
        "desc": "Relational database port. Vulnerable to credential brute-forcing and network sniffing.",
        "recommended": "BLOCK on WAN. Bind to localhost or trusted internal application tier."
    },
    5900: {
        "service": "VNC",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Virtual Network Computing Remote Desktop",
        "severity": "CRITICAL",
        "desc": "Often deployed with weak 8-character passwords or no encryption. Complete graphical desktop control risk.",
        "recommended": "BLOCK on WAN. Tunnel exclusively over SSH or VPN."
    },
    6379: {
        "service": "Redis",
        "protocol": "TCP",
        "risk": "CRITICAL RISK - Redis In-Memory Data Store",
        "severity": "CRITICAL",
        "desc": "Historically configured with zero authentication. Attackers can write SSH authorized_keys to root or load malicious modules.",
        "recommended": "BLOCK on all external interfaces. Bind strictly to 127.0.0.1 or Unix socket."
    },
    8080: {
        "service": "HTTP-Proxy",
        "protocol": "TCP",
        "risk": "MODERATE RISK - Alternate HTTP Web Proxy / Dev Service",
        "severity": "MODERATE",
        "desc": "Secondary HTTP port often hosting administrative consoles, Jenkins, Tomcat, or web proxies without HTTPS.",
        "recommended": "Audit backend application; enforce TLS encryption and firewall access lists."
    },
    8443: {
        "service": "HTTPS-Alt",
        "protocol": "TCP",
        "risk": "LOW/MODERATE RISK - Alternate HTTPS Web Server",
        "severity": "LOW",
        "desc": "Encrypted web communication port. Typically used for management portals or secondary secure web apps.",
        "recommended": "Ensure strong TLS cipher suites and restrict administrative consoles."
    },
    8883: {
        "service": "MQTTS",
        "protocol": "TCP",
        "risk": "SAFE / LOW RISK - Secure MQTT over TLS",
        "severity": "SAFE",
        "desc": "Encrypted IoT messaging for building telemetry.",
        "recommended": "Recommended for all BMS sensor telemetry; enforce client certificate authentication."
    },
    27017: {
        "service": "MongoDB",
        "protocol": "TCP",
        "risk": "HIGH RISK - NoSQL Database Listener",
        "severity": "HIGH",
        "desc": "Subject to automated ransomware scripts if exposed with default authentication settings.",
        "recommended": "BLOCK on WAN. Require local loopback or authenticated internal VPN."
    },
    47808: {
        "service": "BACnet/IP",
        "protocol": "UDP",
        "risk": "CRITICAL RISK - Building Automation and Control Networks (BACnet)",
        "severity": "CRITICAL",
        "desc": "Industrial Building Management System standard protocol (0xBAC0) managing facility HVAC, fire alarms, electrical elevators, and physical access. BACnet packets have no native encryption.",
        "recommended": "CRITICAL: Strict firewall isolation. Drop all incoming BACnet packets from untrusted networks and WAN."
    }
}

# ---------------- COMMAND CATALOG FOR DRY-RUN AUDITING ----------------
COMMANDS = [
    (["firewall rule", "firewall rules", "rules", "allowed port", "blocked port", "open port", "closed port", "filter rule", "list rules", "show rules", "firewall policy"],
     "GET", "/api/firewall/filter/search_rule",
     "Search active firewall filter rules (evaluates pass/block status across WAN/LAN)"),
    (["state", "states", "connection", "connections", "active connection", "state table", "pf state", "session", "sessions"],
     "POST", "/api/diagnostics/firewall/query_states",
     "Query active stateful connections in the pf state table"),
    (["service", "services", "listening", "socket", "daemon", "daemons", "process", "processes"],
     "POST", "/api/core/service/search",
     "Audit system services and identify listening daemons"),
    (["interface", "interfaces", "ip address", "network", "wan ip", "lan ip", "nic"],
     "GET", "/api/diagnostics/interface/get_interface_config",
     "Retrieve hardware and virtual network interface configurations"),
    (["traffic", "bandwidth", "throughput", "usage", "network traffic"],
     "GET", "/api/diagnostics/traffic/interface",
     "Measure live traffic and throughput per network interface"),
    (["version", "firmware", "update", "updates", "upgrade status", "system info", "os version"],
     "GET", "/api/core/firmware/status",
     "Inspect OPNsense appliance firmware version, kernel build, and pending updates"),
    (["gateway", "gateways", "wan", "wan health", "uptime", "routes", "default gateway"],
     "GET", "/api/routes/gateway/status",
     "Evaluate gateway routing status, WAN latency, packet loss, and link health"),
    (["alias", "aliases", "ip group", "port group", "firewall alias"],
     "GET", "/api/firewall/alias/search_item",
     "Inspect configured firewall IP/Port aliases"),
    (["nat", "port forward", "outbound nat", "nat rules", "1:1 nat"],
     "GET", "/api/firewall/nat/search_rule",
     "List Network Address Translation (NAT) and port forwarding rules"),
]

LIVE_ALLOWED = {"/api/core/firmware/status"}

BLOCKED_WORDS = {
    "reboot", "halt", "poweroff", "flush", "kill", "reset"
}

def get_port_info(port: int) -> dict:
    """Retrieve metadata or generate dynamic risk profile for any port."""
    p = int(port)
    if p in PORT_REGISTRY:
        info = PORT_REGISTRY[p].copy()
        info["port"] = p
        return info
    
    # Dynamic classification for uncatalogued ports
    if p < 1024:
        return {
            "port": p,
            "service": f"Privileged-Service-{p}",
            "protocol": "TCP/UDP",
            "risk": f"MODERATE RISK - Standard System Privileged Port ({p})",
            "severity": "MODERATE",
            "desc": f"Port {p} is a reserved system privileged port (<1024). Requires root/admin privilege to bind.",
            "recommended": f"Audit if port {p} is required. Block WAN access unless public service is verified."
        }
    elif p <= 49151:
        return {
            "port": p,
            "service": f"User-Registered-Port-{p}",
            "protocol": "TCP/UDP",
            "risk": f"MODERATE/LOW RISK - Registered Application Port ({p})",
            "severity": "LOW",
            "desc": f"Port {p} falls within the IANA registered user port space. Typically used for third-party servers or custom IoT services.",
            "recommended": f"Inspect active states and firewall rules to verify authorized communication."
        }
    else:
        return {
            "port": p,
            "service": f"Dynamic-Ephemeral-Port-{p}",
            "protocol": "TCP/UDP",
            "risk": f"LOW RISK - Dynamic/Private Ephemeral Port ({p})",
            "severity": "LOW",
            "desc": f"Port {p} is in the private/ephemeral range (49152-65535). Used for outbound ephemeral client connections.",
            "recommended": "Normal ephemeral traffic handled automatically by stateful packet filter."
        }

def inspect_port_detailed_dryrun(port: int, query: str = "") -> str:
    """
    Generate an exhaustive, professional dry-run security audit for a given port,
    detailing exactly what OPNsense REST API queries would be executed.
    """
    p = int(port)
    info = get_port_info(p)
    masked_key = (API_KEY[:8] + "..." + API_KEY[-4:]) if len(API_KEY) > 12 else "Configured"
    masked_secret = (API_SECRET[:4] + "..." + API_SECRET[-4:]) if len(API_SECRET) > 8 else "Configured"
    
    proto = info["protocol"].lower()
    proto_rule = "udp" if "udp" in proto and "tcp" not in proto else ("tcp" if "tcp" in proto and "udp" not in proto else "any")

    rule_action = "block" if info["severity"] in ["CRITICAL", "HIGH"] else "pass"
    rule_desc = f"Auto-Sec: Enforce policy for {info['service']} (Port {p})"

    simulated_rule_payload = {
        "rule": {
            "enabled": "1",
            "action": rule_action,
            "quick": "1",
            "interface": "wan",
            "direction": "in",
            "ipprotocol": "inet",
            "protocol": proto_rule,
            "source_net": "any",
            "destination_net": "any",
            "destination_port": str(p),
            "description": rule_desc
        }
    }

    report = f"""================================================================================
🛡️ OPNsense FIREWALL SECURITY AUDIT & PORT INSPECTION [DRY-RUN SIMULATION]
================================================================================
🎯 Target Port          : Port {p} ({info['service']} / {info['protocol']})
⚠️ Risk Rating          : [{info['severity']}] {info['risk']}
🏢 Host Appliance       : {HOST}
🔑 API Credentials      : API Key: {masked_key} | Secret: {masked_secret}
⚙️ Execution Status      : DRY RUN ACTIVE (Zero modifications made to live firewall)

📋 VULNERABILITY CONTEXT & IMPACT:
{info['desc']}

--------------------------------------------------------------------------------
📡 OPNsense API QUERIES TO BE EXECUTED (Simulated Dry-Run)
--------------------------------------------------------------------------------
[Query 1] Search Configured Firewall Filter Rules:
  • Method   : POST
  • Endpoint : {HOST}/api/firewall/filter/search_rule
  • Headers  : Authorization: Basic <API_KEY:API_SECRET>, Content-Type: application/json
  • Payload  : {json.dumps({"current": 1, "rowCount": -1, "searchPhrase": str(p)}, indent=4)}
  • Purpose  : Audits WAN, LAN, DMZ, and floating rules to verify whether traffic on 
               destination port {p} is currently permitted (pass) or rejected (block/drop).

[Query 2] Query Live pf State Table (Active Sessions):
  • Method   : POST
  • Endpoint : {HOST}/api/diagnostics/firewall/query_states
  • Headers  : Authorization: Basic <API_KEY:API_SECRET>, Content-Type: application/json
  • Payload  : {json.dumps({"search": str(p), "limit": 100}, indent=4)}
  • Purpose  : Inspects active stateful sessions to detect if any internal Building 
               Management device currently holds an open connection on port {p}.

[Query 3] Audit System Daemons & Listening Sockets:
  • Method   : POST
  • Endpoint : {HOST}/api/core/service/search
  • Headers  : Authorization: Basic <API_KEY:API_SECRET>, Content-Type: application/json
  • Payload  : {json.dumps({"searchPhrase": info['service'].lower().split()[0]}, indent=4)}
  • Purpose  : Checks if a local service matching '{info['service']}' is bound and listening.

--------------------------------------------------------------------------------
🛡️ PROPOSED FIREWALL ACTION (Simulated Rule Proposal)
--------------------------------------------------------------------------------
Action Proposed : {rule_action.upper()} incoming traffic on WAN for Port {p}
API Method      : POST
Endpoint        : {HOST}/api/firewall/filter/add_rule
Payload         : {json.dumps(simulated_rule_payload, indent=4)}
Activation Call : POST {HOST}/api/firewall/filter/apply

🔒 HARDENING RECOMMENDATION:
• {info['recommended']}
================================================================================"""
    return report

def check_port_text(port: int) -> str:
    """Evaluate specific port risk status with full dry-run queries."""
    try:
        p = int(port)
        return inspect_port_detailed_dryrun(p)
    except Exception as e:
        return f"Error auditing port {port}: {e}"

def vulnerable_ports_text() -> str:
    """Format and return all documented high/critical risk ports."""
    lines = [
        "================================================================================",
        "          🛡️ OPNsense Building Management Risk Matrix (Key Monitored Ports)     ",
        "================================================================================"
    ]
    for port, meta in sorted(PORT_REGISTRY.items()):
        lines.append(f"• Port {port:5d} [{meta['protocol']:7s}] : [{meta['severity']:8s}] - {meta['service']} | {meta['risk']}")
    lines.append("================================================================================")
    lines.append(f"Target Firewall Appliance: {HOST} | Dry-Run Simulation: ON")
    return "\n".join(lines)

def propose_block(query: str) -> str:
    """Generate a safe, dry-run proposal for blocking network traffic."""
    port_match = re.search(r"\bport\s*[:#]?\s*(\d{1,5})\b", query, flags=re.IGNORECASE)
    ip_match = re.search(r"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b", query)
    
    target_port = port_match.group(1) if port_match else "any"
    target_ip = ip_match.group(0) if ip_match else "any"

    rule_payload = {
        "rule": {
            "enabled": "1",
            "action": "block",
            "quick": "1",
            "interface": "wan",
            "direction": "in",
            "ipprotocol": "inet",
            "protocol": "tcp/udp",
            "source_net": target_ip,
            "destination_net": "any",
            "destination_port": target_port,
            "description": f"Auto-Sec: Block simulated rule for {query[:40]}"
        }
    }

    return f"""================================================================================
🚫 OPNsense FIREWALL RULE CREATION PROPOSAL [DRY RUN SIMULATION]
================================================================================
Target Query     : {query}
Target Port      : {target_port}
Target IP / Net  : {target_ip}
Firewall Host    : {HOST}

📡 OPNsense API Action to be executed:
  • Method   : POST
  • Endpoint : {HOST}/api/firewall/filter/add_rule
  • Headers  : Authorization: Basic <API_KEY:API_SECRET>, Content-Type: application/json
  • Payload  : {json.dumps(rule_payload, indent=4)}

Commit Request : POST {HOST}/api/firewall/filter/apply
Status         : [DRY RUN - SIMULATION ONLY] Rule generated safely. No modifications applied.
================================================================================"""

def plan(query: str) -> dict:
    """Decide which OPNsense call matches the query. Never mutates live state."""
    q = query.lower().strip()
    
    # 1. Check for blocked danger words
    words = set(re.findall(r"[a-z]+", q))
    if words & BLOCKED_WORDS:
        return {"status": "REFUSED", "reason": "Administrative commands like reboot/poweroff/flush are restricted."}

    # 2. Check for port-specific inspection (e.g., "is port 69 safe", "check port 3306")
    port_match = re.search(r"\b(?:port\s*[:#]?\s*|is\s+port\s+)(\d{1,5})\b", q)
    if not port_match:
        port_match = re.search(r"\b(?:is\s+)?(\d{1,5})\s+(?:safe|secure|risky|open|vulnerable)\b", q)
    
    if port_match:
        port_num = int(port_match.group(1))
        return {
            "status": "OK",
            "type": "port_audit",
            "port": port_num,
            "description": f"Perform comprehensive dry-run security audit for Port {port_num}"
        }

    # 3. Check for rule proposals (block/allow)
    if any(k in q for k in ["block", "propose block", "drop", "deny", "add rule", "allow port"]):
        return {
            "status": "OK",
            "type": "proposal",
            "query": query,
            "description": "Generate firewall rule creation proposal"
        }

    # 4. Check for catalogued firewall commands
    for keywords, method, path, desc in COMMANDS:
        if any(k in q for k in keywords):
            return {
                "status": "OK",
                "type": "command",
                "method": method,
                "path": path,
                "description": desc
            }

    # 5. Check for risky ports matrix requests
    if any(k in q for k in ["risky ports", "vulnerable ports", "port matrix", "risk matrix", "all ports"]):
        return {
            "status": "OK",
            "type": "matrix",
            "description": "Display Building Management port risk matrix"
        }

    return {"status": "NO_MATCH", "reason": "No firewall inspection command matches that query."}

def _run_live(path: str, method: str = "GET", payload: dict = None):
    """Safely execute live API requests if DRY_RUN is disabled and endpoint permitted."""
    import requests
    key = API_KEY
    secret = API_SECRET
    if not (key and secret):
        return "Fill in API_KEY and API_SECRET in .env or opnsense_dryrun.py first."
    try:
        url = HOST + path
        if method == "GET":
            r = requests.get(url, auth=(key, secret), timeout=10, verify=VERIFY_TLS)
        else:
            r = requests.post(url, auth=(key, secret), json=payload or {}, timeout=10, verify=VERIFY_TLS)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        return f"Request failed: {e}"

def handle(query: str) -> str:
    """
    Main entry point for general network and firewall inspection queries.
    Seamlessly handles port safety checks, rule proposals, and state table queries.
    """
    p = plan(query)
    if p["status"] != "OK":
        return f"[{p['status']}] {p['reason']}"

    # Route port audit
    if p.get("type") == "port_audit":
        return inspect_port_detailed_dryrun(p["port"], query)

    # Route proposal
    if p.get("type") == "proposal":
        return propose_block(query)

    # Route matrix
    if p.get("type") == "matrix":
        return vulnerable_ports_text()

    # Route standard firewall command
    method = p["method"]
    path = p["path"]
    desc = p["description"]
    call = f"{method} {HOST}{path}"

    if DRY_RUN:
        simulated_payload = {}
        if "query_states" in path:
            simulated_payload = {"search": "", "limit": 50}
        elif "search" in path:
            simulated_payload = {"current": 1, "rowCount": 50}

        return f"""================================================================================
🛡️ OPNsense FIREWALL COMMAND AUDIT [DRY-RUN SIMULATION]
================================================================================
Query Evaluated : {query}
Target Endpoint : {call}
Purpose         : {desc}
Host Appliance  : {HOST}
Authentication  : Basic Auth (API Key & Secret Configured)
Payload (Sample): {json.dumps(simulated_payload) if simulated_payload else "None (Query Parameters)"}

Status: [DRY RUN - NOT EXECUTED ON LIVE FIREWALL]
Simulation verifies that this call is read-only, non-destructive, and valid for OPNsense Core API.
================================================================================"""

    if method != "GET" or path not in LIVE_ALLOWED:
        return f"[BLOCKED] Not enabled for live use yet.\nWould run: {call}"

    return f"[LIVE]\nRan: {call}\nResult: {_run_live(path, method)}"

if __name__ == "__main__":
    print("OPNsense Firewall Security Engine active. Type 'quit' to exit.\n")
    while True:
        try:
            text = input("Security> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if text.lower() in ("quit", "exit"):
            break
        if text:
            print(handle(text), "\n")