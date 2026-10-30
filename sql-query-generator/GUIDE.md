# SQL Query Generator — Quick Start Guide

This guide walks you through setting up and using the SQL Query Generator agent in your local VS Code environment. Supports three schemas: **racadm**, **configadm**, and **prcadm**.

## ⚠️ Important: Separate Databases

- `racadm` is in database `racdb`
- `configadm` is in database `configdb`
- `prcadm` is in database `prcdb`

**You can only query one schema per SQL statement.** For cross-database reporting, run separate queries and join results in your application.

---

## Prerequisites

- **VS Code** (latest version)
- **GitHub Copilot Chat extension** installed
- This repository cloned or unzipped locally

---

## Setup Instructions

### Step 1: Open the Repository in VS Code

1. Unzip the `sql-query-generator` repository (if you received it as a zip file)
2. Open VS Code
3. Go to **File** → **Open Folder**
4. Select the `sql-query-generator` folder
5. Click **Open**

### Step 2: Verify the Extension

1. In VS Code, open the **Extensions** panel (Ctrl+Shift+X / Cmd+Shift+X)
2. Search for **"GitHub Copilot Chat"**
3. If not installed, click **Install**
4. Wait for installation to complete

### Step 3: Activate Copilot Chat

1. Press **Ctrl+Shift+I** (Windows/Linux) or **Cmd+Shift+I** (Mac) to open Copilot Chat
2. You should see the chat panel on the right side of VS Code
3. The workspace instructions from `.github/copilot-instructions.md` will automatically load

---

## How to Use the Agent

### 1. Generate a SQL Query from Plain English

**Command:** `/Generate-SQL-Query`

**Example:**

/Generate-SQL-Query show me all customers from store 08710


**What happens:**
- The agent checks `metadata/schema-index.json` first, then falls back to the relevant schema CSV
- Generates a fully-qualified SQL query
- Returns the query **directly in the chat window** with:
  - The formatted SQL
  - Plain English explanation
  - Parameters you can customize
  - Verified table/column names from the CSV

---

### 2. Find Tables and Columns

**Command:** `/Find-Tables-and-Columns`

**Example:**
/Find-Tables-and-Columns tables related to customer payments


**What happens:**
- Searches the schema metadata
- Lists matching tables with their columns
- Shows data types
- Explains how tables relate to each other

---

### 3. Explain an Existing Query

**Command:** `/Explain-SQL-Query`

**Example:**
/Explain-SQL-Query SELECT * FROM racadm.agreement WHERE close_date IS NULL


**What happens:**
- Explains the query in plain English (and technical language if needed)
- Verifies all tables and columns exist in the CSV
- Flags any potential issues
- Annotates the query with inline comments

---

### 4. Save a Query to File

**Command:** `/Save-Query`

**Example:**

/save-query [paste your SQL query here]

**What happens:**
- Saves the query to `sql/` folder with a header comment
- Includes table names and generation timestamp
- You can reuse this query later

---

## Common Use Cases

### Business Analyst (Non-Technical)

**Goal:** "I need to see all agreements opened last quarter"

1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Type: `/Generate-SQL-Query`
3. Describe: `"Show all agreements opened in Q4 2025"`
4. The agent provides the query in plain language with explanations

**No SQL knowledge required!** The agent explains what the query does.

---

### Developer/DBA (Technical)

**Goal:** "Generate an optimized query for active customers with payment history"

1. Open Copilot Chat
2. Type: `/Generate-SQL-Query`
3. Describe: `"Find active customers with their latest payment date, include CTEs for efficiency"`
4. The agent provides an optimized query with performance notes

**You can request advanced SQL features** like CTEs, window functions, and aggregate queries.

---

### Exploring the Schema

**Goal:** "What data is available about agreements?"

1. Open Copilot Chat
2. Type: `/find-table`
3. Describe: `"agreement tables"`
4. The agent lists all agreement-related tables and their columns

---

## Query Output Format

Every generated query returns in this format in the **chat window**:

**All output appears directly in the chat window.** No files are written unless you explicitly ask with `/save-query`.

---

## Keyboard Shortcuts

| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Open Copilot Chat | Ctrl+Shift+I | Cmd+Shift+I |
| Focus chat input | Ctrl+L | Cmd+L |
| Run a slash command | Type `/` + name | Type `/` + name |
| View command list | Type `/` | Type `/` |

---

## Available Slash Commands (Quick Reference)

| Command | Purpose |
|---------|---------|
| `/Generate-SQL-Query` | Generate SQL from plain English |
| `/Find-Tables-and-Columns` | Search tables and columns in the schema |
| `/Explain-SQL-Query` | Understand a SQL query |
| `/save-query` | Save a finalized query to file |

---

## How to Share This Agent with Others

### Distribute the Repository

1. **Zip the entire `sql-query-generator` folder** — includes metadata, prompts, agents, and guides
2. **Send the zip file** to your colleague
3. They unzip it locally and open in VS Code
4. **All instructions, prompts, and the agent automatically load** — no extra setup!

### For Recipients — Steps to Get Started

1. Unzip the repository anywhere on your machine
2. Open **VS Code**
3. Go to **File** → **Open Folder** → select the `sql-query-generator` folder
4. Install the **GitHub Copilot Chat** extension (if not already installed)
5. Press **Ctrl+Shift+I** to open Copilot Chat
6. Type `/Generate-SQL-Query` and describe the data you need

**No database connection required** — the agent only uses the CSV metadata file included in the repo.

---

## Troubleshooting

### "Slash commands not showing"
- Make sure GitHub Copilot Chat extension is installed and signed in
- Restart VS Code
- Check that `.github/prompts/` folder exists in the workspace

### "Agent not responding"
- Verify the CSV files exist in `metadata/` folder (racadm.csv, configadm.csv, prcadm.csv)
- Check that the folder is opened as a workspace in VS Code (not just a single file)
- Try reloading the window: `Ctrl+Shift+P` → `Developer: Reload Window`

### "Agent not found"
- Agents are invoked via `@agent-name` in chat (e.g. `@sql-query-builder`)
- For most tasks, use the slash commands instead

### "Metadata file not found"
- Ensure the entire repo was extracted — not just a subfolder
- Verify `metadata/racadm.csv`, `metadata/configadm.csv`, and `metadata/prcadm.csv` all exist and are readable

---

## Advanced: Referencing the Agent Directly

Power users can invoke the SQL Builder Agent directly:

@sql-query-builder Generate a CTE-based query showing agreement payment trends by month

---

## Reference Files in This Repository

| File | Purpose |
|------|---------|
| `metadata/racadm.csv` | Racadm schema metadata (rental operations) |
| `metadata/configadm.csv` | Configadm schema metadata (app config/rules) |
| `metadata/prcadm.csv` | Prcadm schema metadata (pricing administration) |
| `metadata/schema-index.json` | Fast column index — checked before CSVs |
| `metadata/relationships.json` | FK join paths between tables |
| `metadata/METADATA_GUIDE.md` | How to search and use the CSV |
| `SQL_GENERATION_GUIDE.md` | Detailed query patterns and examples |
| `prompts/sql_generator_rules.md` | Mandatory SQL generation rules |
| `examples/sample_queries.sql` | Copy-paste reference queries |
| `.github/copilot-instructions.md` | Workspace instructions for Copilot |
| `.github/agents/sql-query-builder.agent.md` | The SQL Builder agent definition |
| `.github/prompts/` | Slash command prompt files |

---

## Next Steps

1. **Open Copilot Chat** in VS Code (`Ctrl+Shift+I`)
2. **Try**: `/Generate-SQL-Query show me all open agreements`
3. **Explore**: `/Find-Tables-and-Columns customer`
4. **Understand**: `/Explain-SQL-Query` then paste any SQL

You're ready to build SQL queries without writing a single line of SQL! 🚀

---

**Questions?** Check the reference files listed above or explore the `.github/` folder for detailed documentation.
