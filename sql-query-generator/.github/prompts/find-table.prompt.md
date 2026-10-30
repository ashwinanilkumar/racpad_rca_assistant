---
description: "Look up tables and columns in the Racadm schema. Use when you want to explore what data is available, find a specific table, or check what columns a table has."
name: "Find Tables and Columns"
argument-hint: "Describe what you're looking for, e.g. 'tables related to payments' or 'columns in the agreement table'"
agent: "agent"
tools: [read, search]
---

Search `metadata/racadm.csv` to find tables and columns matching this request:

## Request

$input

## Instructions

1. Search the CSV file for table names or column names matching the keywords in the request
2. The CSV format is: `table_schema, table_name, column_name, data_type`
3. **Always output directly in the chat window** (do NOT write to any file)
4. Group results by table name
4. For each matching table, list:
   - Full table name (with schema: `racadm.table_name`)
   - Relevant columns found
   - Their data types

## Response Format

### Matching Tables

| Table | Relevant Columns | Data Types |
|-------|-----------------|------------|
| `racadm.table_name` | `column1`, `column2` | bigint, character varying |

### How to Use These Tables
Provide a brief note on how these tables relate to each other (inferred from `*_id` column patterns) and a minimal example JOIN query if multiple tables are found.

### Full Column List
For each table found, list ALL columns so the user knows what's available.
