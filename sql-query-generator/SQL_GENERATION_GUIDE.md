# SQL Generator with CSV Metadata

This document explains how to use the SQL Query Generator with the CSV-based metadata system.

## Quick Start

**Schema discovery:** Scan `metadata/` for all `*.csv` files — each file is one schema.
The filename (without `.csv`) is the schema name (e.g., `racadm.csv` → schema `racadm`).

### Before Generating Queries

1. **Identify the target schema** (from the user request or by listing `*.csv` files in `metadata/`)

2. **Verify table exists:**
   ```bash
   grep "^<schema>,<table>," metadata/<schema>.csv
   ```

3. **Find available columns:**
   ```bash
   grep "^<schema>,<table>," metadata/<schema>.csv | cut -d',' -f3
   ```

4. **Check data types:**
   ```bash
   grep "^<schema>,<table>,<column>," metadata/<schema>.csv
   ```

## Generation Rules

Follow these mandatory rules when generating SQL:

### 1. Schema and Table Names
- **Always qualify tables:** `<schema_name>.table_name`
- **Verify in the correct CSV first** — no invented tables allowed
- **Use exact names** — case-sensitive matching

Example:
```sql
SELECT *
FROM racadm.account_management_activity
WHERE store_id = 100
```

### 2. Column Names
- **Verify each column** exists in the correct schema's CSV for that table
- **Use correct data types** when filtering or joining
- **Respect constraints** — some columns may be nullable

Example:
```sql
-- ✓ CORRECT: Verified columns
SELECT a.account_management_activity_id, a.store_id, a.created_date
FROM racadm.account_management_activity a

-- ✗ WRONG: Column 'shop_id' not verified
SELECT a.shop_id
FROM racadm.account_management_activity a
```

### 3. Joins and Relationships
- **Use explicit JOINs** — no comma-separated table lists
- **Infer relationships** from `*_id` column patterns
- **Verify both sides** of the join exist in the schema's CSV
- **Cross-database queries:** NOT supported in a single SQL statement. Each schema (racadm, configadm, prcadm) is in a separate database. Run separate queries and join results in your application layer.

Example:
```sql
-- ✓ CORRECT: Explicit join with verified columns
SELECT
  a.account_management_activity_id,
  ag.agreement_number
FROM racadm.account_management_activity a
JOIN racadm.agreement ag ON a.agreement_id = ag.agreement_id
WHERE a.created_date > NOW() - INTERVAL '90 days'
```

### 4. Data Type Considerations

**Numeric Columns:**
- `bigint` — Large IDs, counts
- `smallint` — Flags, short values
- `integer` — Sequences, moderate counts
- `numeric` — Money, rates with precision

**Text Columns:**
- `character varying` — All text data
- Use LIKE for pattern matching (case-sensitive by default in PostgreSQL)

**Date/Time Columns:**
- `date` — Date only (no time)
- `timestamp with time zone` — Full datetime with TZ info
- `timestamp without time zone` — Full datetime, no TZ

```sql
-- Timestamp with timezone
WHERE created_date > NOW() - INTERVAL '30 days'

-- Date-only columns
WHERE effective_start_date <= CURRENT_DATE
```

## Common Query Patterns

### Pattern 1: Find Records by Date Range
```sql
SELECT *
FROM <schema>.some_event_table
WHERE event_date >= '2024-01-01'
  AND event_date <= '2024-12-31'
ORDER BY event_date DESC
```

### Pattern 2: Join Related Tables
```sql
SELECT
  a.activity_id,
  a.notes,
  t.desc_en AS activity_type
FROM <schema>.some_activity_table a
JOIN <schema>.some_type_table t
  ON a.type_id = t.type_id
WHERE a.store_id = 5
```

### Pattern 3: Aggregate Data
```sql
SELECT
  store_id,
  COUNT(*) AS total_records,
  MAX(created_date) AS latest_date
FROM <schema>.some_table
GROUP BY store_id
ORDER BY total_records DESC
```

### Pattern 4: Multi-Table Join
```sql
SELECT
  p.parent_id,
  p.reference_number,
  c.child_amount,
  c.child_date
FROM <schema>.parent_table p
JOIN <schema>.child_table c
  ON p.parent_id = c.parent_id
WHERE p.status_type_id = 1
ORDER BY c.child_date DESC
```

### Pattern 5: Filtered Aggregation
```sql
SELECT
  type_id,
  AVG(total_cost) AS avg_cost,
  COUNT(*) AS record_count
FROM <schema>.some_table
WHERE close_date IS NULL
GROUP BY type_id
HAVING COUNT(*) > 10
ORDER BY avg_cost DESC
```

## CSV Metadata Structure for Reference

Each CSV in `metadata/` has this format:

```
"table_schema","table_name","column_name","data_type"
"racadm","account_management_activity","account_management_activity_id","bigint"
"racadm","account_management_activity","store_id","bigint"
```

### Searching the CSV

**Find all columns in a table (PowerShell):**
```powershell
Select-String "^<schema>,<table>," metadata/<schema>.csv | ForEach-Object {$_.Line.Split(',')[2]}
```

**Count distinct tables (PowerShell):**
```powershell
(Select-String "^<schema>," metadata/<schema>.csv |
  ForEach-Object {$_.Line.Split(',')[1]} |
  Sort-Object -Unique).Count
```

**Find all schemas available:**
```powershell
Get-ChildItem metadata/*.csv | ForEach-Object { $_.BaseName }
```

## Validation Checklist

Before returning any generated query:

- [ ] Correct schema CSV was identified and consulted
- [ ] All table names are qualified with `<schema_name>.`
- [ ] All table names exist in the schema's CSV
- [ ] All column names exist for their respective tables in the CSV
- [ ] Data types are used correctly (numeric, text, date operations)
- [ ] JOINs are explicit (not comma-separated)
- [ ] Column aliases are used for clarity
- [ ] Verification note included (which CSV was consulted)

## Example: Building a Complex Query

### Requirement
"Find all agreements with payment history in the last 90 days, including activity details."
*(Schema: racadm)*

### Step 1: Identify Tables Needed
```bash
grep "agreement_payment" metadata/racadm.csv | cut -d',' -f2 | sort -u
grep "account_management_activity" metadata/racadm.csv
```

### Step 2: Identify Key Columns
```bash
grep "^racadm,agreement," metadata/racadm.csv | grep "agreement_id\|number\|status"
grep "^racadm,agreement_payment_history," metadata/racadm.csv | grep "payment\|date"
```

### Step 3: Build and Validate Query
```sql
SELECT
  ag.agreement_id,
  ag.agreement_number,
  aph.payment_amount,
  aph.payment_date,
  ama.notes,
  ama.activity_date
FROM racadm.agreement ag
JOIN racadm.agreement_payment_history aph
  ON ag.agreement_id = aph.agreement_id
LEFT JOIN racadm.account_management_activity ama
  ON ag.agreement_id = ama.agreement_id
WHERE aph.payment_date >= NOW() - INTERVAL '90 days'
ORDER BY aph.payment_date DESC, ag.agreement_number
```

## Troubleshooting Queries

### Issue: "Column does not exist"
**Fix:** Search the correct schema CSV:
```bash
grep ",column_name," metadata/<schema>.csv
```

### Issue: "Type mismatch in comparison"
**Fix:** Check CSV for correct data type and cast if needed:
```sql
WHERE CAST(numeric_column AS bigint) = 100
```

### Issue: "Relation does not exist"
**Fix:** Confirm the table is fully qualified with its schema name:
```sql
-- Wrong
FROM some_table

-- Correct
FROM <schema>.some_table
```

## Best Practices

1. **Always read the correct schema's CSV** — never guess about table/column names
2. **Use meaningful aliases** — e.g., `ama` for `account_management_activity`
3. **Comment complex logic** — explain WHY joins are made
4. **Include audit columns** — consider `created_date`, `last_modified_date` for filtering
5. **Test with LIMIT** — add `LIMIT 100` during development
6. **Handle NULLs** — use `IS NULL` / `IS NOT NULL` appropriately
7. **Format cleanly** — proper indentation for readability
