---
name: Financial Modeling Feedback
description: Lessons learned from building Arx financial projections v3-v5 — what to do and not do when building financial models
type: feedback
---

## Financial Model Building Rules (from Mar 2026 session)

### 1. Growth rates drive MAU, not marketing budgets

**Why:** Marketing ÷ CAC produces flat acquisition per month, not compounding growth. The growth rate IS the assumption. Marketing is a cost, CAC is derived.
**How to apply:** Always model MAU as: `MAU(t) = MAU(t-1) × (1 + growth_rate - churn)`. Never as: `Marketing / CAC × activation`.

### 2. Never decompose ARPU from trades × size × bps

**Why:** Crypto trading follows a power law. The "average" trade size is meaningless — 9% of users (Profit Centers) generate 85% of fees. Decomposition produces wrong numbers.
**How to apply:** Use Flowscan's observed ARPU directly (Desktop: $159, Copy: $94). Show decomposition as a footnote, not a formula input.

### 3. Show the work — present inputs BEFORE building

**Why:** Gary corrected the model 5+ times because assumptions weren't validated upfront. "Show me the key drivers first, let me confirm, then compute."
**How to apply:** For any financial model, ALWAYS present the driver table with suggested values and benchmarks FIRST. Get confirmation. Then build.

### 4. Use Advance Wealth methodology for structure

**Why:** AW projections are the internal standard Gary is familiar with. Same sheet structure, color coding, notes column.
**How to apply:** Summary → P&L → Revenues (per product) → Costs (categorized) → Staff Model → Benchmarks. Notes column on every row.

### 5. Match marketing to original projections when told to

**Why:** Gary has already approved a UA marketing budget. Don't invent new numbers.
**How to apply:** Read the original projection file first, carry over verified numbers.

### 6. Never reference Gary by name in financial models

**Why:** Investor materials shouldn't have founder names in role titles.
**How to apply:** "CEO / Founder" not "CEO / Founder (Gary)".

### 7. Breakeven must be mathematically verified

**Why:** v4-v5 had formula bugs (MATCH/INDEX not evaluating, cumulative P&L wrong).
**How to apply:** Pre-compute in Python, verify, then write to Excel. Show the month-by-month cumulative P&L trace.

### 8. No KYC/AML, trade surveillance, or licensing fees for Arx

**Why:** Arx is a non-custodial DeFi frontend, not a regulated broker.
**How to apply:** Only budget external legal counsel. Cloud at $25K+/yr. Pen tests quarterly at $30K each.

### 9. Staff model: scale engineers, not compliance

**Why:** AI productivity handles compliance/QA. The real scaling need is mobile (iOS/Android), on-chain, backend, big data, DevOps.
**How to apply:** Strategic hires = engineering + product scaling. No dedicated compliance or QA roles.

### 10. Advance Group provides shared services at no cost Y1

**Why:** Same model as Advance Wealth. Finance/accounting, legal, HR provided by group. Chargeback starts Y2.
**How to apply:** $0 for support functions Y1. Budget $10K/mo chargeback from Y2.
