---
description: "Find what code changed recently in a rentacenter repo and whether it could be causing a regression. Returns commits, diffs, and risk assessment."
mode: agent
---

# What Changed

## Inputs needed
- **Repo name** (e.g. `racpad_agreement`, `es_inventorypackage`) — required
- **Symptom or bug** observed (e.g. "EPO shows wrong amount since last week")
- **Date range** — approximate date the issue started (e.g. "started around 2025-11-15")
- **File or folder** to narrow down (optional, e.g. `client/src/components/AgreementDetails`)

---

## What this prompt does

Investigates recent code changes as a potential cause for a regression:

1. Fetches the last 20 commits from the repo (filtered to the date range if given)
2. For each relevant commit, fetches the full diff to show exactly what lines changed
3. Cross-references the changed files against the symptom described
4. Flags any commit that touched calculation logic, feature flags, DB queries, or API contracts
5. Provides a risk assessment: **Likely cause / Possible cause / Unrelated**
6. Links directly to the GitHub commit URL for easy review

---

## Start

Investigate recent changes that may have caused the following issue:

**Repo:** [REPO_NAME]
**Symptom:** [DESCRIBE_THE_BUG_OR_REGRESSION]
**Issue started around:** [DATE]
**File / folder to narrow down (optional):** [PATH]
