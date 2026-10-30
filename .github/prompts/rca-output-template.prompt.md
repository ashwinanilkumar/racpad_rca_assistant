---
description: "HTML output template for RAC RCA reports. Word-ready format — paste directly into Microsoft Word."
mode: agent
---

# RCA Output Template

Write the completed RCA to `rca-output/RCA-[INCIDENT-ID]-[YYYY-MM-DD].html` using the file editing tools.

**Rules:**
- Keep under 4 pages in Word (~2000 words, excluding appendix)
- TL;DR at the very top — stakeholders read this first
- Use `<code>` for inline values, `<pre>` for multi-line code/queries, `<table border="1">` for evidence tables

```html
<!DOCTYPE html>
<html>
<body style="font-family: Calibri, Arial, sans-serif; font-size: 11pt; line-height: 1.4;">

<h1>Root Cause Analysis — [INCIDENT ID]</h1>
<p><b>TL;DR:</b> [One sentence: root cause + fix]</p>

<h2>1. Issue Summary</h2>
<p>[1–2 sentences — what happened vs expected]</p>

<h2>2. Inputs</h2>
<ul>
  <li><b>Agreement/Entity ID:</b> [value]</li>
  <li><b>CorrelationId:</b> <code>[value]</code></li>
  <li><b>Timestamp:</b> [value]</li>
  <li><b>Store:</b> [value]</li>
</ul>

<h2>3. Hypotheses</h2>
<ol>
  <li>[Hypothesis 1] — <i>Confidence: High/Medium/Low</i></li>
  <li>[Hypothesis 2] — <i>Confidence: High/Medium/Low</i></li>
</ol>

<h2>4. Evidence</h2>
<h3>4a. Code Evidence</h3>
<table border="1" cellpadding="6" cellspacing="0">
  <tr><th>File</th><th>Lines</th><th>Finding</th><th>Supports Hypothesis</th></tr>
  <tr><td><code>[file path]</code></td><td>[L45-52]</td><td>[what the code does]</td><td>#1 ✓</td></tr>
</table>

<h3>4b. DB Evidence</h3>
<table border="1" cellpadding="6" cellspacing="0">
  <tr><th>Query</th><th>Key Result</th><th>Supports Hypothesis</th></tr>
  <tr><td><code>[SQL summary]</code></td><td>[value]</td><td>#1 ✓</td></tr>
</table>

<h3>4c. Log Evidence</h3>
<table border="1" cellpadding="6" cellspacing="0">
  <tr><th>Platform</th><th>Query</th><th>Key Finding</th></tr>
  <tr><td>Grafana</td><td><code>[query]</code></td><td>[what logs showed]</td></tr>
</table>

<h2>5. Root Cause</h2>
<p><b>[One sentence — confirmed root cause with file:line reference]</b></p>

<h2>5b. Commit / Jira / Release Attribution</h2>
<p><i>This section answers the Support team's question: "Which change caused this and when was it deployed?"</i></p>
<table border="1" cellpadding="6" cellspacing="0">
  <tr style="background:#f2f2f2">
    <th>Field</th><th>Value</th>
  </tr>
  <tr><td><b>Introducing Commit</b></td><td><code>[SHA — first 8 chars]</code> — "[commit message]"</td></tr>
  <tr><td><b>Committed By</b></td><td>[Author name / GitHub handle]</td></tr>
  <tr><td><b>Commit Date</b></td><td>[YYYY-MM-DD]</td></tr>
  <tr><td><b>Jira Ticket</b></td><td><code>[e.g. RAC-4512 / FLX-321]</code> — [ticket title if extractable from commit msg] — or "Not found in commit message"</td></tr>
  <tr><td><b>Pull Request</b></td><td>#[PR number] — or "Could not be determined"</td></tr>
  <tr><td><b>Release / Deployment</b></td><td>[Release tag / deploy date / sprint name] — or "Not tagged — estimated from commit date [YYYY-MM-DD]"</td></tr>
  <tr><td><b>Repo</b></td><td>[repo name]</td></tr>
  <tr><td><b>Files Changed</b></td><td><code>[file path(s) from diff]</code></td></tr>
  <tr><td><b>Before This Commit</b></td><td>[What the code did before — from diff old lines (−)]</td></tr>
  <tr><td><b>After This Commit</b></td><td>[What the code does now — from diff new lines (+)]</td></tr>
  <tr><td><b>Regression?</b></td><td>[Yes — behaviour changed by this commit] / [No — logic gap present since initial implementation (commit [SHA])]</td></tr>
</table>
<p><b>Support Communication Template:</b><br/>
<i>"This issue was introduced in the <b>[release tag / deploy date]</b> deployment of <b>[repo]</b>,
via Jira <b>[ticket ID]</b> (PR #[NNN]), committed on [date] by [author].
The fix requires [brief fix description]."</i>
</p>

<h2>6. Calculation Proof</h2>
<pre>
fullTRTO      = rate × term  = $X × Y  = $Z
exchangeTotal = $Z − rentPaid = $Z − $W = $V
SAC           = $V × 0.65   = $U
[show every step with real numbers]
</pre>

<h2>7. Verdict</h2>
<p><b>[System Bug | Working as Designed | Process Gap | Data Issue]</b></p>
<p><b>Confidence:</b> [High (90%+) | Medium (70-89%) | Low (&lt;70%)] — [justification]</p>

<h2>8. Scope / Blast Radius</h2>
<ul>
  <li><b>Agreements affected:</b> [count]</li>
  <li><b>Stores affected:</b> [count]</li>
  <li><b>Date range:</b> [start – end or "ongoing"]</li>
  <li><b>Escalation needed:</b> [Yes (50+ agreements or ongoing) / No]</li>
</ul>

<h2>9. Resolution</h2>
<ul>
  <li><b>Fix:</b> [code change / DB correction / config change / process step]</li>
  <li><b>Mitigation:</b> [immediate workaround if any]</li>
  <li><b>Prevention:</b> [test, validation, monitoring]</li>
</ul>

<h2>10. Appendix</h2>
<h3>SQL Queries Used</h3>
<pre>[All SQL from SQL Query Builder]</pre>
<h3>Log Queries</h3>
<pre>[Grafana / CloudWatch queries for the user to run]</pre>

</body>
</html>
```
