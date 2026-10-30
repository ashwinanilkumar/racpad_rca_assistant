---
description: "Understand exactly how a feature, screen, or service works in the rentacenter codebase. Traces the full flow from UI → API → DB."
mode: agent
---

# Functionality Check

## Inputs needed
- **Feature or flow to understand** (e.g. "RAC Exchange pricing", "EPO calculation", "agreement creation with reinstatement")
- **Module / repo** if known (e.g. `racpad_agreement`, `es_inventorypackage`) — leave blank to search org-wide
- **Specific function or component** if known (e.g. `calculateExchangeAgreementPricing`)

---

## What this prompt does

Traces the complete end-to-end flow of a feature:

1. **UI layer** — finds the relevant React/Angular component in `racpad_` repos; identifies what data is sent to the API
2. **API / service layer** — finds the backend service (`es_` / `ess_`) that handles the request; reads the core logic
3. **DB layer** — identifies what tables are read/written and what SQL queries run
4. **Calculation logic** — for financial flows (SAC, EPO, TRTO, rates) reproduces the formula with example numbers
5. **Feature flags** — identifies any `featureFlagDetails` keys that control the behaviour
6. **Error paths** — lists what error messages or validation failures can occur

Delivers a plain-English explanation with exact file references and code snippets.

---

## Start

Explain how the following works in the rentacenter codebase:

**Feature / Flow:** [FEATURE_OR_FLOW_NAME]
**Module / Repo (optional):** [MODULE_OR_REPO]
**Specific function (optional):** [FUNCTION_NAME]
**Any context or related terms:** [KEYWORDS_OR_CONTEXT]
