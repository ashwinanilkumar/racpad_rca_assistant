---
description: "Explain what a SQL query does in plain English. Use when you have a query and want to understand it, or want to check if it's correct before running."
name: "Explain SQL Query"
argument-hint: "Paste a SQL query to explain, or describe which query file to open"
agent: "agent"
tools: [read, search]
---

Explain the provided SQL query clearly for both technical and non-technical audiences.

## Metadata Source
Verify any tables/columns mentioned against [racadm.csv](../metadata/racadm.csv).

## User Request
**$ARGUMENTS**

If no query is provided in the arguments, read [sql/new_query.sql](../sql/new_query.sql).

## Instructions

**Always output directly in the chat window** (do NOT write to any file).

### Step 1 — Parse the Query
Identify:
- Tables being queried
- JOIN conditions linking tables
- WHERE clause filters
- GROUP BY / HAVING aggregations
- ORDER BY sorting
- Any subqueries, CTEs, or window functions

### Step 2 — Verify Against CSV
For each table referenced:
- Confirm it exists in `metadata/racadm.csv`
- Verify that each column used belongs to that table
- Check data types are used correctly

Flag any issues found:
- ⚠️ Table not found in CSV
- ⚠️ Column not found on that table
- ⚠️ Potential data type mismatch

### Step 3 — Explain in Plain English

**Provide two explanations:**

#### For Non-Technical Users
Write a simple, conversational explanation:
- "This query pulls a list of..."
- "It filters to only show..."
- "The results are grouped by... and sorted by..."
- Explain what each column in the results represents

#### For Technical Users
Write a concise technical summary:
- What indexes might be used
- Whether the JOINs look correct
- Any performance concerns (missing filters, large table scans)
- Suggestions to improve or simplify

### Step 4 — Annotated Query
Return the original query with inline comments added:

```sql
-- [Overall description]
SELECT
  a.agreement_id,          -- Unique identifier for the agreement
  a.total_cost,            -- Total contract value
  ...
FROM racadm.agreement a    -- Main agreement table
JOIN racadm.agreement_payment_history aph
  ON a.agreement_id = aph.agreement_id  -- Links agreement to its payments
WHERE a.close_date IS NULL -- Only active (not closed) agreements
```

### Step 5 — Verdict

End with a clear verdict:
- ✅ **Query looks correct** — ready to run
- ⚠️ **Minor issues found** — list them
- ❌ **Issues that will cause errors** — explain what to fix
