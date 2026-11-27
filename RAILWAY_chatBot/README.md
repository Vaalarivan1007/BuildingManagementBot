# 🚆 RAILWAY_chatBot - Autonomous Railway Network Operations Smart ChatBot

Dedicated, standalone AI Chatbot tailored for the **Railway Central Network Management & Control System** (`OMCSMGMT_2_0_0`). Built with the same dark-mode conversational UI, interactive Plotly visualizations, dataframes, bookmarks, and persistent memory features as the Building Management System (BMS) agent.

---

## ⚡ Quick Launch

### Option 1: Double-Click Desktop / Folder Launcher
Simply double-click:
- `c:\Users\Vallarivan\RAILWAY_chatBot.bat` OR
- `c:\Users\Vallarivan\RAILWAY_chatBot\RAILWAY_chatBot.bat`

### Option 2: Terminal / PowerShell Command
```powershell
cd c:\Users\Vallarivan\RAILWAY_chatBot
python -m streamlit run app.py
```

---

## 🔌 Database Details & Connectivity
- **Target DB**: `OMCSMGMT_2_0_0` (173 relational tables)
- **Live Endpoint**: `10.20.31.15:3306`
- **Read-Only Credentials**: Configured via `.env` (refer to `.env.example`).
- **Safety**: Built-in SQL sanitizer blocks any mutating statements (`DROP`, `DELETE`, `UPDATE`, `INSERT`).

---

## 🚀 Key Features for Today's Demo

1. **Conversational Natural Language Interface**:
   - Ask questions like: *"Show all active critical alarms"*, *"Plot active alarm severity distribution"*, *"Check offline network elements"*, *"What is the current SNMP polling status of all nodes?"*
2. **Instant Demo Suggestion Chips**:
   - `🔴 Critical Alarms`
   - `📊 Plot Severities`
   - `🟠 Offline Devices`
   - `🟢 SNMP Health`
   - `🏢 Stations List`
3. **Interactive DataFrames & Plotly Visualizations**:
   - Automatic Donut charts for Severity Distributions.
   - Bar charts for alarm concentration across Subsystems (MOC/MOI).
   - JSON export button (`📋 Export Query Data (.json)`) on every data query.
4. **Live Executed SQL & Latency**:
   - Executed SQL code expander with precise execution latency.
   - Live Executed SQL commands history in the sidebar (last 5 queries with timers).
5. **Categorized Bookmarks System**:
   - Group saved queries into custom folders (`Alarm Audits`, `Network Elements`, `SNMP Health & Stations`, `General`).
   - 1-click execution of bookmarked queries.
6. **Persistent Train DB Memory**:
   - SQLite backed (`railway_train_db.sqlite`).
   - Remembers custom aliases, rules, and operator preferences across sessions.
