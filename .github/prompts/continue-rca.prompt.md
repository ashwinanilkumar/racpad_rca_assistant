---
description: "Inject new evidence into an in-progress RCA without restarting. Use when you have DB query results, log data, or additional context to add after the initial investigation has begun."
mode: agent
---

# Continue RCA — New Evidence

## When to use this
Use this prompt when:
- The team has run a DB query and you have results to add
- You have log data from Grafana / Splunk / CloudWatch
- A hypothesis has been confirmed or ruled out and you want to continue
- You received clarification from the store or dev team

---

## Provide the following

**Incident ID:** [INCIDENT_ID]

**What was established so far:** (brief summary — e.g. "We confirmed the exchange agreement was created before the reversal was processed")

**New data received:**
```
[PASTE DB QUERY RESULTS, LOG SNIPPETS, OR ADDITIONAL CONTEXT HERE]
```

**Source of new data:** [e.g. "racadm query on agreement_payment_history" / "Grafana log" / "store team confirmed" / "dev team clarified"]

**What question this answers:** [e.g. "This confirms/refutes Hypothesis 2 — timing race condition"]

**Current open questions (if any):**
- [ ] [Question 1 still unanswered]
- [ ] [Question 2 still unanswered]

---

## Instructions

1. Accept the new data as ground truth if it is a DB query result or confirmed log output
2. Re-evaluate all open hypotheses against the new evidence
3. State explicitly: does this new data **confirm**, **refute**, or **remain neutral** on each hypothesis?
4. If all hypotheses are now resolved → deliver the final verdict in the RCA format:
   - **Verdict**: System Bug / Working as Designed / Process Gap / Data Issue
   - **Root Cause**: one sentence with file:line reference if code was involved
   - **Resolution**: what action is needed (DB correction / code fix / process change / no action)
5. If open questions remain → state exactly what is still needed to close the investigation
6. Once verdict is final → ask: *"RCA confirmed — shall I generate the document?"*

> Do NOT generate the HTML document until the user explicitly confirms.
