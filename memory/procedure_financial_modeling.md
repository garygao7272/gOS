---
name: Financial Modeling Procedure
description: Step-by-step workflow for editing Excel financial models — OfficeCLI + LibreOffice verification
type: procedure
valid_from: 2026-04-08
valid_to: open
---

## How to Edit Financial Models (.xlsx)

1. **Read** — Use OfficeCLI to read current state: `officecli read <file>`
2. **Edit** — Use OfficeCLI for writes: `officecli edit <file>` — NEVER use openpyxl
3. **Recalc** — Verify formulas with LibreOffice headless: `soffice --headless --calc --convert-to xlsx <file>`
4. **Audit** — Cross-check key outputs: breakeven, MAU projections, ARPU
5. **Drivers first** — Always show growth rate assumptions before building formulas
6. **Observed ARPU** — Use actual observed ARPU, not aspirational targets

## When to Use

Any task involving `.xlsx` or `.xls` files, especially revenue projections and unit economics.
