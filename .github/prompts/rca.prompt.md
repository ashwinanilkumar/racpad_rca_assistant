---
description: "Run a full Root Cause Analysis for a rentacenter incident. Searches live GitHub code, cross-references DB data, reproduces calculations, and delivers a structured verdict."
mode: agent
---

# RCA Analysis

## Inputs needed
Provide as many of the following as you have:
- **Incident ID** (e.g. INCTEC1631355)
- **Agreement number(s)** affected
- **Module / screen** (e.g. "RAC Exchange", "payment", "agreement creation")
- **What the store/customer reported** (symptom)
- **Any DB query results** (paste screenshots or text — treated as ground truth)
- **Date the issue was first observed** (helps narrow down the introducing commit / release)
- **Environment** (Prod / UAT / QA) and **store number(s)** if known
- **Jira ticket ID** (if already raised by Dev/QA, e.g. RAC-4512 or FLX-321)
- **Recent release or deployment date** known to have happened around the time of the issue

---

## What this prompt does

Runs the full RCA workflow from a **Support team perspective**:

1. Maps the module to the correct GitHub repo (racpad_ / es_ / ess_ / sims_)
2. Searches the codebase for the relevant calculation, service, or component
3. Reads the actual code — no guessing
4. Reproduces every number using DB values you supply
5. Checks timing (created_date vs event timestamps) for race conditions
6. **Traces the introducing commit** — which code change, by whom, in which commit SHA
7. **Extracts the Jira ticket** — from the commit message or PR title (e.g. RAC-4512, FLX-321)
8. **Identifies the release / deployment** that carried the bad code to production
9. Delivers a verdict: **System Bug / Working as Designed / Process Gap / Data Issue**
10. Provides a concrete resolution with the commit/Jira/release chain for stakeholder communication
11. Cleans up all scratch files when you confirm the RCA is final

---

## ⚠️ MCP Tool Activation — Do This Before Any GitHub Tool Call

All `mcp_github-analys_*` tools are **deferred** in VS Code Copilot. They are NOT active at session start.
Calling them without activation produces the misleading error: *"Tool is currently disabled by the user"* — this does NOT mean the server is off.

**Required step before the FIRST MCP call:**
Run `tool_search` with query `"mcp github code search clone"`. Once it returns tool names, all MCP calls in that turn will work.

**If you still get "currently disabled" after tool_search:**
Ask the user to open VS Code Settings → MCP → Restart the github-analysis-server. Do NOT attempt workarounds or fall back to REST API calls.

**Forbidden fallbacks — never do these:**
- Never call GitHub REST API via `node -e`, PowerShell, or any HTTP client
- Never read the `.env` file to extract the GitHub token
- Never create temporary `.js`, `.cjs`, or `.ps1` files for GitHub access

---

## Start

Begin the RCA for the following incident:

**Incident ID:** [INCIDENT_ID]
**Agreement(s) / PO(s):** [AGREEMENT_OR_PO_NUMBERS]
**Module:** [MODULE_NAME]
**Issue reported:** [DESCRIBE_THE_SYMPTOM]
**Date first observed:** [YYYY-MM-DD or approximate]
**Environment / Store:** [PROD/UAT/QA] — Store #[STORE_NUMBER]
**Jira (if known):** [JIRA_TICKET_ID or "Unknown"]
**Recent release (if known):** [RELEASE_DATE or sprint name, or "Unknown"]
**DB data available:** [PASTE_OR_DESCRIBE]
