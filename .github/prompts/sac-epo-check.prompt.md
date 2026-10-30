---
description: "Verify and reproduce SAC, EPO, or TRTO calculations for any rentacenter agreement. Provide DB values and get a step-by-step proof of what the system should have computed vs what it stored."
mode: agent
---

# SAC / EPO / TRTO Calculation Check

## Inputs needed
Provide the DB values you have (run the query below if needed):

```sql
-- Agreements
SELECT agreement_id, weekly_rate, weekly_term, total_cost, cash_price
FROM racadm.agreement
WHERE agreement_id IN ('<new_agreement_id>', '<parent_agreement_id>');

-- Payment history on parent
SELECT agreement_payment_history_id, payment_date, payment_amount,
       rental_revenue, reversed_agr_payment_hist_id, created_date
FROM racadm.agreement_payment_history
WHERE agreement_id = <parent_agreement_id>
ORDER BY created_date;

-- Exchange agreement created_date
SELECT agreement_id, open_date, created_date
FROM racadm.agreement
WHERE agreement_id = <new_agreement_id>;
```

Fill in below:
- **New agreement ID:** [ID]
- **Parent agreement ID:** [ID]
- **Agreement DB data:** [paste query results]
- **Payment history data:** [paste query results]
- **Item's full price tag term** (from store/pricing team): [weekly_term]
- **Cash price multiplier** (typically 0.65): [multiplier]
- **Payment schedule** (weekly / bi-weekly / monthly): [schedule]

---

## What this prompt does

1. Derives the full TRTO from the item's price tag (`rate × fullTerm`)
2. Sums `rental_revenue` from payment history — only payments posted **before** the exchange `created_date`
3. Computes `exchangeTotal`, `exchangeTerm`, and `SAC` step by step
4. Compares against what is stored in the DB
5. Identifies any discrepancy and explains the cause (timing race, wrong multiplier, reversal in SUM, etc.)
6. States the correct values and the delta

---

## Start

Verify the SAC/EPO calculation for the following agreement:

**New agreement:** [NEW_AGREEMENT_ID]
**Parent agreement:** [PARENT_AGREEMENT_ID]
**DB data:** [PASTE_HERE]
**Payment history:** [PASTE_HERE]
**Full item weekly_term (price tag):** [TERM]
**Payment schedule:** [bi-weekly / weekly / monthly]
