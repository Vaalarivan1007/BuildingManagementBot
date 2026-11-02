# ⚡ Building Management System — MCP Multi-Agent Architecture

An AI-driven Building Management System (BMS) converted into a **Model Context Protocol (MCP)** multi-agent system. Decoupled agents communicate via standard **JSON-RPC stdio** transport to handle electrical telemetry analytics, thermal safety audits, and OPNsense firewall security.

---

## 🏛️ Architecture Overview
+-----------------------+
                              |   User Prompt (UI)    |
                              +-----------+-----------+
                                          |
                                          v
                              +-----------------------+
                              |   Master Orchestrator |
                              |    (orchestrator.py)  |
                              +---+-------+-------+---+
                                  |       |       |
             JSON-RPC (stdio)     |       |       |     JSON-RPC (stdio)
         +------------------------+       |       +-------------------------+
         |                                v                                 |
         v                        JSON-RPC (stdio)                          v
+--------------------------+    +---------------------------+    +--------------------------+
|  Voltage Telemetry Agent |    | Current & Thermal Agent   |    | Security & Network Agent |
| (voltage_mcp_server.py)  |    |(current_energy_mcp_server)|    | (security_mcp_server.py) |
+--------------------------+    +---------------------------+    +--------------------------+
| - query_voltage_metrics  |    | - query_current_energy    |    | - inspect_network        |
| - phase_voltage_checks   |    | - thermal_imbalance_check |    | - check_port_risk        |
+--------------------------+    +---------------------------+    | - propose_firewall_rule  |

---

## 🤖 Specialized MCP Agents

1. **Security & Network Agent (`security_mcp_server.py`)**
   * Inspects OPNsense firewall configurations, checks risky ports (e.g., 3306, 22, 80), and generates dry-run rule proposals.

2. **Voltage Telemetry Agent (`voltage_mcp_server.py`)**
   * Translates natural language queries into SQL to audit $R/Y/B$ phase voltages (`virv`, `viyv`, `vibv`) and neutral voltage potential (`vinv`).

3. **Current & Thermal Telemetry Agent (`current_energy_mcp_server.py`)**
   * Monitors phase currents (`viri`, `viyi`, `vibi`), current imbalance percentages (`vicurrentimbalance`), panel enclosure thermal levels (`vitemp`), and cumulative energy usage (`vienergy`).

4. **Master Agent Orchestrator (`orchestrator.py`)**
   * Parses combined multi-agent prompts, dispatches RPC calls to the respective agent stdio processes, and aggregates their outputs into a unified response.

---

## 🚀 Quickstart Guide

### 1. Install Dependencies
```powershell
pip install -r requirements.txt