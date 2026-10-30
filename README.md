# RAC RCA Assistant — Standard Operating Procedure (SOP)

Investigation toolkit for the Rent-A-Center (`rentacenter`) support team. It connects GitHub Copilot Chat to the GitHub org through a local MCP server, and adds a validated SQL query generator for the three databases. Use it to run root cause analyses (RCA) on store incidents, backed by real code and real DB data.

> **Read-only.** This workspace is for investigation only. It must never create PRs, commits, branches, issues or comments, or push or modify anything in GitHub. Copilot is configured to refuse such requests.

---

## 1. What is in this repo

| Path | Purpose |
|------|---------|
| `server.js` | Local MCP server exposing GitHub investigation tools (Section 8) |
| `.vscode/mcp.json` | Registers the server as `github-analys` in VS Code |
| `.github/copilot-instructions.md` | Always-on rules: terminology, RCA workflow, read-only restriction |
| `.github/prompts/` | Slash commands (Section 6) |
| `.github/agents/` | Agents `rac-rca` and `SQL Query Builder` (Section 7) |
| `sql-query-generator/` | Schema metadata and SQL generation rules for `racadm`, `configadm`, `prcadm` (Section 9) |
| `rca-output/` | Generated RCA documents (created on first use) |
| `.env` | Your GitHub token (you create it, never committed) |

---

## 2. Prerequisites

| Requirement | Check |
|-------------|-------|
| VS Code with GitHub Copilot and Copilot Chat, signed in | Copilot icon in the status bar |
| Node.js 18 or later | `node -v` |
| Git, available in PATH | `git --version` |
| GitHub Personal Access Token (PAT) with `repo` and `read:org` scopes, **SSO-authorized for `rentacenter`** | See step 3.3 |

---

## 3. First-time setup

### 3.1 Clone and install

```powershell
git clone <this-repo-url>
cd github-rca-assistant
npm install
```

### 3.2 Create `.env` in the repo root

```
GITHUB_TOKEN=ghp_your_token_here
GITHUB_ORG=rentacenter
```

`GITHUB_TOKEN` is required: the server exits at startup without it. `GITHUB_ORG` defaults to `rentacenter`. `.env` is in `.gitignore`; never commit or share it.

### 3.3 Create and authorize the token

1. Open https://github.com/settings/tokens and generate a token with `repo` and `read:org`.
2. Click **Configure SSO** next to the token, then **Authorize** for `rentacenter`.
3. Paste the token into `.env`.

### 3.4 Open the folder in VS Code

1. **File > Open Folder** and select the repo root (not a subfolder). This is required for `.github/` prompts, agents and `.vscode/mcp.json` to load.
2. Run **MCP: List Servers** from the Command Palette and confirm `github-analys` is **Running**. If it is not, choose **Start Server**.
3. Open Copilot Chat (Ctrl+Alt+I) and switch to **Agent** mode.
4. Click the tools icon and confirm the `github-analys` tools are enabled.

### 3.5 Verify the setup

In Copilot Chat, ask:

```
List the open PRs for racpad_agreement
```

A list of PRs (or "none") means the token, SSO and server are working. See Section 11 if you get an error.

---

## 4. Core concepts

| Term | Meaning |
|------|---------|
| **TRTO** | Total Rent To Own = Rate × Term |
| **SAC** | Same As Cash price = TRTO × `cashPriceMultiplier` (typically 0.65) |
| **EPO** | Early Purchase Option. During the SAC period, EPO = SAC |
| **RAC Exchange** | Customer swaps a rental item. Rent paid on the old agreement reduces the term of the new one |
| Exchange formula | `exchangeTotal = fullTRTO - rentPaid`, then `term = ceil(exchangeTotal / rate)`, then `SAC = exchangeTotal × multiplier` |
| `agreement_payment_history` | DB table of every payment event. `SUM(rental_revenue)` is total rent credited |
| `featureFlagDetails` | Runtime feature flags that control UI behaviour in `racpad_` repos |

### Repo naming

| Prefix | Type | Example |
|--------|------|---------|
| `racpad_` | Store UI (frontend) | `racpad_agreement`, `racpad_payment` |
| `es_` | Backend microservices | `es_agreementcreate` |
| `ess_` | Enterprise shared services | `ess-ts-common` |
| `sims_` | SIMS store/inventory system | `sims_POS` |
| `mariner_` | Customer portal | `mariner_customerportal` |
| `van_` | VAN engagement | |
| `rac-devops_` | DevOps / infra | |

---

## 5. Standard procedure: investigating an incident

Follow these steps in order. The assistant is configured to follow the same flow.

1. **Start the RCA.** In Agent mode, type `/rca` and paste the incident ID or description plus any DB values, screenshots or logs.
2. **Review the hypotheses.** The assistant restates the problem and lists candidate causes before gathering evidence.
3. **Provide DB evidence when asked.** Use `/generate-db-query` (or the `SQL Query Builder` agent) to get a validated query. Run it yourself against the right database (Section 9) and paste the results back with `/continue-rca`.
4. **Verify calculations.** For SAC, EPO or TRTO issues, use `/sac-epo-check` with the stored DB values. The assistant shows every arithmetic step.
5. **Check recent changes.** Use `/what-changed` to find recent commits or diffs that may have caused a regression.
6. **Read the verdict.** It will be one of: **System Bug**, **Working as Designed**, **Process Gap** or **Data Issue**, with the supporting code and data evidence.
7. **Confirm.** The assistant asks: *"RCA confirmed — shall I generate the document?"* Reply **yes** only when you agree with the findings.
8. **Generate the document.** On confirmation, `/rca-output-template` creates a Word-ready HTML file in `rca-output/`. Open it in a browser, copy it and paste it into Word.
9. **Clean up.** Once the RCA is agreed, the assistant runs `cleanup_analysis_files` with `confirm: true` to delete scratch `.cjs` proof scripts and clear the repo cache.

Rules the assistant follows (and you should too):
- Never assume. Verify from DB data or code.
- Provide real timestamps (`created_date`) when timing matters. The assistant will not guess them.
- Your DB results are treated as ground truth.
- A "System Bug" verdict needs code evidence. A "Working as Designed" verdict needs confirmed data and timing at the moment of the event.

---

## 6. Slash commands

Type `/` in Copilot Chat (Agent mode).

| Command | Use when |
|---------|----------|
| `/rca` | Starting a full incident investigation |
| `/continue-rca` | Adding new DB results or logs to an in-progress RCA |
| `/generate-db-query` | You need a validated SQL query for `racadm`, `configadm` or `prcadm` |
| `/functionality-check` | "How does feature X work?" Traces UI, API and DB |
| `/sac-epo-check` | Verifying SAC, EPO or TRTO from DB values |
| `/what-changed` | Looking for a recent commit that may have caused a regression |
| `/rca-output-template` | Generating the final Word-ready HTML report (after confirmation) |

Example inputs:

```
/generate-db-query racadm: payment history for agreement 123456
/generate-db-query configadm: param config for SameAsCashDays at US country level
/generate-db-query prcadm: product prices for zone 5
/what-changed racpad_agreement, AgreementTransfer folder, last 10 commits
```

---

## 7. Agents

Select from the agent dropdown in Copilot Chat.

| Agent | Purpose |
|-------|---------|
| `rac-rca` | RCA specialist for store incidents, SAC/EPO/TRTO, RAC Exchange and payment discrepancies. Searches live code, reproduces calculations and delivers a verdict |
| `SQL Query Builder` | Builds SQL for racadm/configadm/prcadm and explains results. Used by `rac-rca` whenever DB evidence is needed |

---

## 8. MCP tools reference

Copilot picks these automatically. You can also name them in a prompt.

### Find code

| Tool | Use for | Limit |
|------|---------|-------|
| `fetch_issue_context` | Plain-English issue to relevant files. Best when the repo is unknown (set `module`) | GitHub Search: 10/min |
| `search_code` | Find which repo or file contains a symbol | GitHub Search: 10/min |
| `multi_repo_search` | Find a symbol across all repos with a prefix (default `racpad_`) | GitHub Search: 10/min |
| `clone_and_search` | Exact regex search in a known repo, with context lines. Prefer this once the repo is known | None |
| `resolve_repo` | Map a module name and prefix to a verified repo | API |

### Understand a screen or service

| Tool | Use for |
|------|---------|
| `find_feature_flags` | All `featureFlagDetails` references in a repo |
| `find_error_messages` | User-facing errors, alerts and popup strings |
| `get_api_calls` | Backend endpoints called by a component or the whole frontend |
| `analyze_repo` / `analyze_code` | Structure summary of a repo, or a quick quality check of a snippet |

### Change history

| Tool | Use for |
|------|---------|
| `get_recent_commits` | Recent commits, optionally filtered by file or folder |
| `get_commit_diff` | Full diff for a commit SHA |
| `get_open_prs` | Open PRs, to check whether a fix is already in progress |

### Navigation and maintenance

| Tool | Use for |
|------|---------|
| `list_org_repos` | List org repos with language and last-updated date |
| `get_repo_files` | List a directory in any repo |
| `get_file_content` | Read a file |
| `list_cached_repos` | Show repos in the local clone cache with commit SHA and age |
| `cleanup_analysis_files` | Delete scratch `.cjs` files and clear the cache. Requires `confirm: true` |

### How the clone cache works

Clone-based tools (`clone_and_search`, `find_feature_flags`, `find_error_messages`, `get_api_calls`) keep repos cached in memory for the life of the MCP server (maximum 5, oldest evicted first). On each use, the live HEAD SHA is checked with `git ls-remote`, and the repo is re-cloned if it changed. Restarting the MCP server clears the cache.

### Which tool should I use?

| Situation | Tool |
|-----------|------|
| Don't know which repo | `fetch_issue_context` with `module` |
| Know the repo, need an exact pattern | `clone_and_search` |
| Something broke recently | `get_recent_commits`, then `get_commit_diff` |
| Which flag controls this screen | `find_feature_flags` |
| What error can appear here | `find_error_messages` |
| Is a fix already in flight | `get_open_prs` |

---

## 9. SQL query generator

Located in `sql-query-generator/`. It generates queries only from verified schema metadata, so it never invents tables or columns.

### Databases

Each schema is in a **separate database**. A query cannot join across them.

| Schema | Database | Contents |
|--------|----------|----------|
| `racadm` | `racdb` | Rental operations: agreements, customers, payments, inventory, stores |
| `configadm` | `configdb` | App configuration: business rules, roles, store settings |
| `prcadm` | `prcdb` | Pricing: product prices, zones, queues, uploads |

For cross-database questions, run one query per database and combine the results yourself. For example, `prcadm` `rms_item_master_id` links to `racadm.inventory`.

### Metadata files (`sql-query-generator/metadata/`)

| File | Role |
|------|------|
| `racadm.csv`, `configadm.csv`, `prcadm.csv` | Ground truth: one row per column (`table_schema, table_name, column_name, data_type`) |
| `schema-index.json` | Compact table and column index. Checked first. Partition child tables (suffix `_YYYY_MM`, `_YYYY`, `_pN`, `_default`) are listed under `_partitions`; query the parent table |
| `relationships.json` | FK join paths, including cross-schema links |
| `METADATA_GUIDE.md` | Detailed guide to the metadata |

### Generating a query

1. Run `/generate-db-query <schema>: <what you need>` from the repo root.
2. Check the verification note in the answer. It states which tables and columns were confirmed and from which source.
3. Run the SQL in the correct database with your DB client.
4. Always use schema-qualified names (`racadm.agreement`) and explicit `JOIN` syntax.

The `sql-query-generator/` folder also has its own prompts when it is opened as its own workspace: `/generate-query`, `/find-table`, `/explain-query` and `/save-query`. Saved queries go in `sql-query-generator/sql/`; examples are in `examples/sample_queries.sql`.

### Refreshing metadata after a schema change

1. Export the current columns for each schema from its database, one schema per run:

```sql
SELECT c.table_schema, c.table_name, c.column_name, c.data_type
FROM information_schema.columns c
JOIN information_schema.tables t
  ON t.table_schema = c.table_schema AND t.table_name = c.table_name
WHERE c.table_schema = 'racadm'          -- repeat for 'configadm', 'prcadm'
  AND t.table_type = 'BASE TABLE'
ORDER BY c.table_name, c.ordinal_position;
```

2. Save each result as `metadata/<schema>.csv` (UTF-8, all values quoted, header row `"table_schema","table_name","column_name","data_type"`).
3. Ask Copilot to compare the CSVs with `schema-index.json` and `relationships.json` and update them. Stale column names and missing tables are the usual differences.
4. Review the changes, especially any joins that were inferred automatically.

---

## 10. Quick recipes

| Scenario | What to ask |
|----------|-------------|
| Button is greyed out | `clone_and_search` in `racpad_<module>`, pattern `disabled`, path filter on the component folder |
| Error popup appeared | `find_error_messages` for the repo and component |
| Broke after a deploy | `/what-changed <repo>`, then `get_commit_diff` on the suspect SHA |
| What flag controls this | `find_feature_flags` for the repo |
| Where is this API called | `clone_and_search` with the API function names |
| Might be a backend issue | `multi_repo_search` with prefix `es` |
| SAC/EPO looks wrong | `/sac-epo-check` with the stored DB values |

---

## 11. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Server exits immediately | `.env` is missing or `GITHUB_TOKEN` is empty. Create it as in 3.2 |
| `Resource protected by organization SAML enforcement` | Token not SSO-authorized. Redo step 3.3 |
| `Bad credentials` | Token expired or revoked. Generate a new one and update `.env`, then restart the server |
| `git: command not found` | Install Git and add it to PATH, then restart VS Code |
| `github-analys` tools missing in chat | Use Agent mode, open the repo root as the workspace, run **MCP: List Servers**, then **Restart Server** |
| Slash commands or agents not listed | The folder opened is not the repo root, or `.github/` is missing |
| `No matching code found` | Use a more specific symbol or give the repo name explicitly |
| Search rate limit errors | `search_code`, `fetch_issue_context` and `multi_repo_search` allow 10 per minute. Switch to `clone_and_search` |
| Query uses a column that doesn't exist | Metadata is stale. Refresh it as in Section 9 |

After changing `.env` or `server.js`, restart with **MCP: Restart Server**.

---

## 12. Do and don't

- Do give the assistant real DB values, timestamps and screenshots.
- Do confirm the verdict before asking for the document.
- Do run `cleanup_analysis_files` after an RCA is agreed.
- Don't ask it to raise a PR, commit or comment. It will refuse.
- Don't commit `.env` or paste your token into chat.
- Don't join across `racdb`, `configdb` and `prcdb` in one SQL statement.
