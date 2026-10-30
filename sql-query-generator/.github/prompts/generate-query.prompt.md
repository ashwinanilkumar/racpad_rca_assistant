---
description: "Generate a SQL query from a plain English description. Works for racadm, configadm, and prcadm schemas."
name: "Generate SQL Query"
argument-hint: "Describe what data you need and which schema (racadm, configadm, or prcadm), e.g. 'prcadm: product prices for zone 5' or 'configadm: param config for SameAsCashDays at US country level'"
agent: "agent"
tools: [read, search]
---

Use the [Racadm SQL Builder](./../agents/sql-query-builder.agent.md) agent to generate a SQL query for the following request.

## ⚠️ DATABASE CONSTRAINT
Each schema is in a separate database — **do NOT generate SQL that joins tables from different schemas**. If the user asks for cross-database queries, run separate queries and advise them to join results in their application.

## Request

$input

## Instructions for the Agent

### Step 0 — Confirm Schema (MANDATORY BEFORE ANYTHING ELSE)
- If the schema is stated in the request (e.g. "in configadm", "in racadm", "in prcadm"), use it
- If not stated, infer from the table/entity names mentioned
- If still unclear, ask the user: *"Which schema — racadm (rental ops), configadm (app config/rules), or prcadm (pricing admin)?"* (Note: Each schema is in a separate database, so only one can be queried per SQL statement.)
- State which schema you are using at the top of your response

### Step 1 — Look Up Metadata (Use Index First — No Unnecessary CSV Reads)
1. Read `metadata/schema-index.json` → find the relevant tables and their columns
2. Read `metadata/relationships.json` → find JOIN paths
3. Only read `metadata/<schema>.csv` if the table is not in the schema-index

### Step 2 — Generate SQL
- Fully-qualified table names: `schema_name.table_name`
- Explicit JOINs only — no comma-separated tables
- Meaningful aliases
- Inline `-- comments` for clarity

### Step 3 — Respond in Chat (Never Write to Files Unless Asked)
Respond with:
- The formatted SQL query with inline comments
- Plain English explanation of what it returns
- A table of parameters the user can customize
- A note confirming which tables/columns were verified and from which source (schema-index or CSV)

If important information is missing (like a date range or filter value), show the query with a placeholder (e.g., `'YYYY-MM-DD'` or `-- replace with your value`) and explain what to fill in.
