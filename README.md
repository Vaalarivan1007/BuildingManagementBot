# ⚡ Building Management AI Master Agent & OPNsense Security Integration

An end-to-end, AI-powered **Building Management System (BMS)** dashboard and natural language Text-to-SQL telemetry analytics engine. Built with **Streamlit**, **Ollama** (Qwen 2.5 Coder), **MySQL**, and integrated with an **OPNsense** firewall inspection module.

---

## 🌟 Key Features

- **Natural Language Text-to-SQL**: Translates user questions into executable SQL queries for BMS telemetry data.
- **Local AI Pipelines**: Configured for local inference via **Ollama** and **Qwen 2.5 Coder**, keeping telemetry and logs private.
- **Persistent AI Memory (`train_db`)**: SQLite-backed adaptive memory store for custom user aliases, domain rules, and preference mappings.
- **Interactive Telemetry Visualization**: Auto-renders multi-device time-series trends using custom Plotly Grafana-inspired dark theme charts.
- **Integrated Voice Input & Live Translation**: Embedded microphone UI component for spoken queries with real-time audio handling.
- **Weather & Research Analytics**: Real-time atmospheric predictions integrated directly into chat workflows.
- **OPNsense Firewall Security Module**: Safe, read-only diagnostic lookup and proposal generation for open ports, active states, and firewall rule recommendations.

---

## 📁 Repository Structure & Module Breakdown

| File / Module | Description |
| :--- | :--- |
| **`app.py`** | Primary **Streamlit** web UI application. Handles session state, database setup sidebar, live executed SQL logs, Plotly visual charts, bookmark management, and main execution pipeline. |
| **`main.py`** | Entry point and script orchestration module. |
| **`llm_engine.py`** | Core LLM engine wrapper around **Ollama / Qwen2.5-Coder**. Handles SQL generation from natural language prompts, query error recovery retries, and output synthesis. |
| **`schema_reader.py`** | Database schema introspection tool. Connects to MySQL/SQLite databases, inspects table structures, column types, primary keys, and dynamically formats schema definitions into context prompts. |
| **`sql_validator.py`** | Security and query safety enforcement module. Parses, validates, formats, and sanitizes generated SQL queries (restricting DDL/DML destructive statements like `DROP`, `DELETE`, `UPDATE`). |
| **`knowledge_base.py`** | Domain knowledge exporter module. Packages telemetry definitions, nominal electrical ranges, system safety rules, and few-shot golden SQL examples into standard JSON and Markdown documentation formats. |
| **`opnsense_dryrun.py` / `opn.py`** | Read-only OPNsense firewall helper. Parses query intents to check network state, active sockets, and interface traffic, while providing write proposals for blocking ports/sites without making modifications. |
| **`voice_module.py`** | Audio interface module. Injects voice recording components and CSS styles into Streamlit to capture speech queries directly in the UI. |
| **`weather_module.py`** | Weather lookup and predictive engine module for integrating atmospheric conditions into building operational insights. |
| **`train_db.sqlite`** | Local persistent SQLite database storing learned agent memory, user preferences, and custom entity mapping aliases. |
| **`requirements.txt`** | List of Python dependencies required to run the application suite. |

---

## ⚡ Quick Start & Installation

### 1. Prerequisites
- **Python**: Version 3.10 or higher
- **Ollama**: Installed and running locally (`ollama serve`) with `qwen2.5-coder` pulled (`ollama pull qwen2.5-coder`)
- **MySQL Database**: Running instance with BMS telemetry schemas

### 2. Setup Environment

```bash
# Clone the repository (or your fork)
git clone [https://github.com/shoyotobiyo/BuildingManagementBot.git](https://github.com/shoyotobiyo/BuildingManagementBot.git)
cd BuildingManagementBot

# Create and activate virtual environment
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt