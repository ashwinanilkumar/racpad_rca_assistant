# Metadata Guide — Multi-Schema CSV System

This guide explains how to work with the CSV-based metadata system for the SQL Query Generator.

## How Schemas Are Discovered

Each `*.csv` file in this folder represents **one schema**:
- The filename (without `.csv`) is the schema name
- Example: `racadm.csv` → schema `racadm`, `configadm.csv` → schema `configadm`
- **To add a new schema:** drop a new `<schema_name>.csv` file in this folder — no other changes needed

## File Overview

**File per schema:** `metadata/<schema_name>.csv`  
**Format:** CSV (Comma-Separated Values)  
**Encoding:** UTF-8  
**Columns:** table_schema, table_name, column_name, data_type  

## Understanding the CSV Structure

Each row represents a single column definition in the database:

```
table_schema, table_name, column_name, data_type
racadm, account_management_activity, account_management_activity_id, bigint
racadm, account_management_activity, store_id, bigint
racadm, account_management_activity, customer_id, bigint
```

### Important Notes:

1. **One column per row** - Each row defines a single column in a table
2. **Schema prefix** - The `table_schema` column matches the CSV filename (schema name)
3. **Multiple rows per table** - Tables appear multiple times (once per column)
4. **Unique tables** - To list all unique tables, group by `table_name`

## How to Query a CSV

Replace `<schema>` and `<table>` with actual names.

### Using grep (Linux/Mac/PowerShell)

**Find all columns in a specific table:**
```bash
grep "^<schema>,<table>," <schema>.csv
```

**Count tables in a schema:**
```bash
cut -d',' -f2 <schema>.csv | sort -u | wc -l
```

**Find tables with a specific column pattern:**
```bash
grep "account_id" <schema>.csv
```

### Using standard database tools

**Load into PostgreSQL:**
```sql
COPY schema_info FROM '<schema>.csv' WITH CSV HEADER;
```

**Load into SQLite:**
```sql
.mode csv
.import <schema>.csv schema_info
```

## Column Types Distribution (Common Across Schemas)

- **bigint** - Primary and foreign key IDs
- **character varying** - Text fields, codes, descriptions
- **numeric** - Money, rates, percentages
- **timestamp with time zone** - Created/modified dates
- **date** - Transaction, event dates
- **smallint** - Flags, short enumerations
- **integer** - Sequences, short counts

## Common Patterns

### Primary Key Pattern
Most tables have a primary key column named `{table_name}_id`:
```
account_management_activity → account_management_activity_id
agreement → agreement_id
address → address_id
```

### Foreign Key Pattern
Foreign keys follow the pattern `{referenced_table}_id`:
```
account_management_activity has: person_id, store_id, customer_id
```

### Audit Columns
Most tables include audit/tracking columns:
```
created_by (character varying)
created_date (timestamp with time zone)
last_modified_by (character varying)
last_modified_date (timestamp with time zone)
```

### Multilingual Support
Many descriptor columns are duplicated for languages:
```
desc_en (English description)
desc_es (Spanish description)
```

## Data Quality Notes

1. **Consistency** - Column names and data types are consistent within each schema
2. **Naming conventions** - Uses snake_case for all identifiers
3. **No special characters** - Safe for SQL generation
4. **Timestamps** - Mix of with/without timezone awareness — handle carefully

## Using This Metadata for SQL Generation

### Step 1: Identify the Schema
Determine which schema CSV to use based on the user's request or by listing available `*.csv` files.

### Step 2: Find the Right Table
Search the schema's CSV for tables matching your business entity:
```bash
grep ",account_" <schema>.csv | cut -d',' -f2 | sort -u
```

### Step 3: Identify Columns
Once you know the table, find its columns:
```bash
grep "^<schema>,<table>," <schema>.csv
```

### Step 4: Check Data Types
Verify the data type matches your query requirements:
- Numeric operations: Use `numeric`, `bigint`, `smallint`, `integer`
- Text matching: Use `character varying`
- Date filtering: Use `date`, `timestamp with time zone`, `timestamp without time zone`

### Step 5: Reference in Queries
Always use fully qualified names:
```sql
SELECT a.some_id, a.some_column
FROM <schema>.some_table a
WHERE a.created_date >= '2024-01-01'
```

## Troubleshooting

### "Table not found"
- Check if table name is spelled correctly
- Verify it exists in the correct schema's CSV
- Remember to qualify with schema: `<schema_name>.table_name`

### "Column not found"
- Search for the column in the correct schema's CSV
- Check the actual table name (may be different than expected)
- Verify spelling and case sensitivity

### "Data type mismatch"
- Check the column data type in the schema's CSV
- Use appropriate conversion functions for type mismatches
- Example: `CAST(numeric_col AS text)` or `TO_DATE(text_col, 'YYYY-MM-DD')`

## Maintenance

### Adding a New Schema
1. Export schema information from the database in CSV format
2. Save as `metadata/<schema_name>.csv` (filename must match schema name)
3. Ensure consistent formatting: `table_schema, table_name, column_name, data_type`
4. No other configuration needed — the agent auto-discovers all `*.csv` files

### Adding New Tables to an Existing Schema
1. Export the new table's column definitions in CSV format
2. Append rows to the existing `metadata/<schema_name>.csv`
3. Validate no duplicate rows

### Updating Column Types
- Modify the `data_type` value for the specific row in the relevant CSV
- Ensure consistency across the file

## Performance Tips

- Keep each CSV sorted by `table_name` for easier searching
- Use grep with anchors for precise matches: `^<schema>,table_name,`
- Index by `table_name` when loading into database tools
- Consider creating a searchable database table for large schemas (1000+ tables)
