---
description: "Save a new SQL query to the sql/ folder. Use when you have a finalized query you want to store for reuse."
name: "Save Query"
argument-hint: "Provide the query to save and optionally a filename (without .sql extension)"
agent: "agent"
tools: [read, edit]
---

Save the provided SQL query into the `sql/` folder of this workspace.

## Instructions

**Save the query to a file only when explicitly requested by the user.**

### 1. Get the Query
The user's input is: **$ARGUMENTS**

If the argument contains a SQL query, use that.
If not, read the most recently discussed query from context.

### 2. Determine Filename
- If the user specified a name, use that (append `.sql` if missing)
- If not, infer a short descriptive name from the query content (e.g., `active_agreements_by_store.sql`)
- Never overwrite `new_query.sql` — that's the scratch file

### 3. Add File Header
Prepend a header comment to the saved file:

```sql
-- ============================================================
-- Query: [descriptive title]
-- Description: [one-line description of what it returns]
-- Tables: [comma-separated list of main tables used]
-- Generated: [today's date]
-- ============================================================

[the SQL query]
```

### 4. Save the File
Write to `sql/[filename].sql`.

### 5. Confirm
Report back:
- File path saved to
- One-line summary of what the query does
- Reminder: The query targets only ONE database/schema. Verify columns against the appropriate metadata CSV before running in production.
