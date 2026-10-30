# SQL Query Generator

A SQL query generation system that leverages a comprehensive CSV-based metadata catalog for enterprise PostgreSQL databases: **racadm**, **configadm**, and **prcadm**.

## Overview

This system uses schema-specific CSV files in `metadata/` as the authoritative source for all schema, table, and column definitions. A pre-computed `schema-index.json` enables fast lookups without reading the full CSVs for every query.

## Project Structure

```
sql-query-generator/
├── metadata/
│   ├── racadm.csv              # Racadm schema metadata (rental operations)
│   ├── configadm.csv           # Configadm schema metadata (app config/rules)
│   ├── prcadm.csv              # Prcadm schema metadata (pricing administration)
│   ├── schema-index.json       # Compact column index — check this FIRST before CSVs
│   ├── relationships.json      # Table relationship and FK definitions
│   └── METADATA_GUIDE.md       # How to work with CSV metadata
├── prompts/
│   ├── instructions.md          # Agent role and rules
│   └── sql_generator_rules.md  # SQL generation guidelines and rules
├── examples/
│   └── sample_queries.sql      # Example queries for reference
└── README.md                   # This file
```

### Critical Constraint: Separate Databases

Each schema is located in a separate database and **cannot be queried together in a single SQL statement**:

| Schema | Database | Purpose |
|--------|----------|---------|
| `racadm` | `racdb` | Core rental operations |
| `configadm` | `configdb` | Application configuration |
| `prcadm` | `prcdb` | Pricing administration |

**For cross-database reporting:** Run separate queries against each database and join the results in your application or reporting tool.

## Supported Schemas

| Schema | Purpose |
|--------|---------|
| `racadm` | Core rental operations: agreements, customers, payments, inventory, store activity |
| `configadm` | Application configuration: business rules, user roles, store settings, org hierarchy |
| `prcadm` | Pricing administration: product prices, rate zones, pricing queues, pricing uploads |

## Metadata Format

### CSV files (`metadata/<schema>.csv`)

Each CSV contains the complete database schema with the following columns:

| Column | Description |
|--------|-------------|
| table_schema | Schema name (e.g., `racadm`, `configadm`, `prcadm`) |
| table_name | Complete table name |
| column_name | Column name in the table |
| data_type | PostgreSQL data type |

### schema-index.json

A compact pre-indexed summary of all tables and columns across all schemas. **Always check this first** — avoids full CSV reads for common lookups.

### relationships.json

Pre-computed FK join paths for all schemas, including cross-schema links (e.g., `prcadm.rms_item_master_id` → `racadm.inventory`).

## How to Use

### 1. Query Generation Process

When generating SQL queries:
1. Reference **`metadata/schema-index.json`** first for tables and columns
2. Fall back to **`metadata/<schema>.csv`** only if a table is missing from the index
3. Check **`metadata/relationships.json`** for JOIN paths
4. Always use fully qualified table names: `<schema_name>.table_name`
5. Use explicit JOIN syntax — never comma-separated tables
6. Do NOT invent tables or columns

### 2. Common Tasks

#### Find a table
```
grep "table_name" metadata/<schema>.csv
```

#### Find columns in a table
```
grep "<schema>,<table>," metadata/<schema>.csv
```

#### Check column data type
```
grep "<schema>,<table>,<column>" metadata/<schema>.csv
```

### 3. SQL Generation Rules

See `prompts/sql_generator_rules.md` for the complete set of rules followed during SQL generation.

## Data Types Reference

- **bigint** — 8-byte integer (IDs, counts)
- **smallint** — 2-byte integer (flags, short numbers)
- **integer** — 4-byte integer (sequences, counts)
- **numeric** — Fixed decimal (money, percentages)
- **character varying** — Variable-length text
- **date** — Date without time
- **timestamp with time zone** — Full datetime with timezone
- **timestamp without time zone** — Full datetime without timezone

## Examples

See `examples/sample_queries.sql` for example queries.

## SQL Generation Best Practices

1. **Always qualify tables**: Use `<schema>.table_name`
2. **Check schema-index.json first**: Faster than reading CSVs
3. **Use meaningful aliases**: e.g., `ama` for `account_management_activity`
4. **Use explicit JOINs**: Avoid implicit joins with commas
5. **Handle timestamps carefully**: Use appropriate functions for TZ handling

## Adding a New Schema

1. Export schema columns from the database as CSV with columns: `table_schema, table_name, column_name, data_type`
2. Save as `metadata/<schema_name>.csv`
3. Add the schema's tables to `metadata/schema-index.json`
4. Add the schema's FK relationships to `metadata/relationships.json`
5. Update the agent description in `.github/agents/sql-query-builder.agent.md` and `.github/copilot-instructions.md`
