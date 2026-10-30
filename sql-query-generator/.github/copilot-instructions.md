# Multi-Schema SQL Query Generator — Workspace Instructions

This workspace is a SQL query generator for **enterprise PostgreSQL databases**. It supports multiple schemas simultaneously. Each schema is represented by a dedicated CSV file in the `metadata/` folder.

## ⚠️ CRITICAL: Separate Databases — No Cross-Schema SQL Joins

**Each schema is in a separate database:**
- `racadm` → `racdb`
- `configadm` → `configdb`
- `prcadm` → `prcdb`

**You CANNOT join tables across these databases in a single SQL query.** Each schema must be queried independently. If you need data from multiple schemas, run separate queries against each database and join the results in your application/reporting layer.

---
## ⚡ OPTIMIZED LOOKUP STRATEGY (Use This Order — Do Not Skip)

To minimize context usage, always look up in this order:

1. **`metadata/schema-index.json`** — Check this FIRST for table names and columns. It's a compact map of every table in every schema. No need to read CSVs for simple column lookups.
2. **`metadata/relationships.json`** — Check this for JOIN paths between tables. Tells you which FK columns connect which tables, including cross-schema links.
3. **`metadata/<schema>.csv`** — Only open a CSV if a table is NOT in the schema-index OR you need to confirm an edge-case column. The CSV is the ground truth but expensive to read.

> If the table exists in `schema-index.json` and the columns you need are listed there — **do not read the CSV**. You have everything you need.

## MANDATORY FIRST STEP — Ask Schema Before Starting

**Before generating any SQL, always ask:**

> "Which schema is this query for? Available schemas: **racadm**, **configadm**, **prcadm**"

- If the user names a schema explicitly → proceed immediately
- If the user is unsure → briefly describe each:
  - `racadm` — core rental operations: agreements, customers, payments, inventory, store activity
  - `configadm` — application configuration: business rules (param_config/param_key), user roles, store settings, org hierarchy
  - `prcadm` — pricing administration: product pricing rules, rate zones, pricing queues, pricing uploads, SAC days
- If the entity/table pattern makes it unambiguous (e.g., "param_config" → configadm, "agreement" → racadm, "product_price" / "pricing_queue" / "cost_pricing_rule" → prcadm) → infer and state which schema you're using
- **NOTE:** If a user asks for data spanning multiple schemas (e.g., prcadm + racadm), explain that separate queries are required. State: "I'll need to run two separate queries — one against prcadm and one against racadm — since the schemas are in different databases. You'll join the results in your application layer."

## Metadata Source

**Single source of truth for validation:** `metadata/<schema_name>.csv` (one CSV per schema)
- Format: `table_schema, table_name, column_name, data_type`
- The CSV filename matches the schema name
- **Only read CSVs when** the schema-index doesn't cover the table/column you need

**Schema discovery:** Three schemas exist: `racadm`, `configadm`, and `prcadm`. All are indexed in `metadata/schema-index.json`.

**Never** invent tables, columns, or data types.

## SQL Rules

- Fully-qualify all table names: `<schema_name>.table_name`
- Use explicit `JOIN ... ON ...` syntax — never comma-separated tables
- Use meaningful aliases (e.g., `ama` for `account_management_activity`)
- Always check column data types in schema-index.json (bigint, smallint, numeric, varchar, date, timestamptz)
- Prefer `timestamp with time zone` awareness in date filters

## Common Schema Guidance (No CSV Read Needed)

### racadm — Key patterns
- `agreement` = core rental contract. `agreement_number` is the business key (varchar)
- `agreement_status_type.ref_code` = ACTIVE / CLOSED / EARLY_PURCHASE / CHARGED_OFF
- `account_management_activity` = customer contact/call log
- `*_type`, `*_subtype` tables = reference/lookup; have `ref_code`, `desc_en`, `desc_es`
- `*_archive`, `*_archive_2024` = historical copies of main tables
- `sac_days` and `sac_days_printed` exist on: `inventory_price`, `override_activity`, `rms_item_exception`

### configadm — Key patterns
- **Application config flow**: `param_config` → JOIN `param_key` (rule name) + `association` (scope) + `param_config_list_of_value` (value)
- `association.association_ref_code` = scope identifier (e.g., `'US'` for USA country)
- `association_type.association_type_name` = scope level: `'COUNTRY'`, `'STORE'`, `'STATE'`
- `ent_business_rule` = denormalized view-like table; useful for quick single-table lookups without joins
- User/role tables mirror `racadm` schema

### prcadm — Key patterns
- **Pricing flow**: `pricing_param_value` → JOIN `pricing_param_key` (rule name) + `item_price_hierarchy` (scope/zone)
- `product_price` = published final price per item/zone; contains `sac_days`, `sac_days_printed`, `epo_pct`, all rate frequencies
- `pricing_queue` + `pricing_queue_stage` = pending pricing changes; filter by `queue_status_type.ref_code`
- `pricing_upload` = tracks uploaded pricing files and their processing status
- `cost_pricing_rule` = min/max rate constraints per zone/department/bracket
- `pricing_param_key.pricing_param_key_name` is the pricing rule name (analogous to configadm.param_key.param_key_name)
- `sac_days` and `sac_days_printed` exist on: `product_price`, `pricing_queue_stage`
- Cross-schema: `rms_item_master_id` links prcadm tables to `racadm.inventory`; `store_id` in `pricing_queue_stage`/`company_store` links to `racadm.store`

## Audience

- **Non-technical**: plain English explanations, label each SQL clause
- **Technical**: CTEs/window functions where helpful, include performance tips

## Response Format for Query Generation

1. The SQL query, clean and formatted, shown directly in the chat window (do NOT write to any file unless explicitly requested)
2. Plain English: what it returns
3. Customization hints: what values/filters to change
4. Verification note: which tables/columns were confirmed (from schema-index.json or CSV)

## Key Reference Files

- `metadata/schema-index.json` — **START HERE** — compact table/column index (no CSV reads needed for common tables)
- `metadata/relationships.json` — FK join paths between tables
- `prompts/sql_generator_rules.md` — mandatory SQL generation rules
- `SQL_GENERATION_GUIDE.md` — query patterns and validation checklist
- `metadata/METADATA_GUIDE.md` — CSV structure guide
- `examples/sample_queries.sql` — copy-paste reference queries
