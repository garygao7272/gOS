---
name: Financial Modeling Session Learnings
description: Deep session on financial projections — Gary's preferences on model structure, benchmarking, and investor readiness
type: feedback
---

## Key Learnings

1. **Marketing costs must match source file exactly for M1-12, then cap at % of revenue for M13+.** Gary wants Valen's CPA-driven values preserved for launch phase. Never apply Valen's absolute values beyond M12 — they were designed for a different growth rate.

2. **ARPU should be uniform across scenarios.** ARPU = user trading behavior, not company execution. Only growth and churn should vary between scenarios.

3. **No separate "acceleration" budget.** Gary prefers all marketing under one line (Growth Model / Valen budget). If more growth is needed, adjust the growth rate assumption, not a separate spend row.

4. **Protection Fund and GBP are not P&L items.** Gary explicitly removed both. GBP is already included in marketing channels. Protection fund is a trust/regulatory item, not modeled.

5. **Capital = Peak Burn × 1.20.** No separate operational reserve — the 20% buffer is sufficient. No fixed $5M hardcode. Formula-driven from actuals.

6. **Conservative scenario should still reach breakeven** — use lean execution (staff×0.85, opex×0.85, fewer CMs) as the lever, not impossibly low growth.

7. **Growth rates must be below or at BasedApp's 32.6%.** Gary wants to be defensible as "slightly below the market leader," not above.

8. **MAU FY1 Total should show end-of-period value (M12), not SUM.** Revenue/cost FY1 should show SUM. This confused Gary in the screenshot.

9. **Referral decay at M12** (not M18 or M24). Gary wants shorter affiliate sunset.

10. **Every cell except inputs must be a formula.** Gary checks this repeatedly. No hardcoded outcomes.

**Why:** Gary is building an investor-ready model. Every number must trace back to an assumption. He values benchmark grounding (BasedApp, Flowscan data) over theoretical derivations.

**How to apply:** Always validate growth/churn against BasedApp Flowscan data before presenting. Never hardcode outcomes. Marketing = Valen M1-12, % of revenue M13+.

## Tool Rules (added 2026-04-07)

11. **NEVER use openpyxl for writing to financial models.** openpyxl corrupts complex workbooks: strips macros, named ranges, complex formatting. `delete_rows()` doesn't update formula references. See anthropics/claude-code#22044.
12. **Use OfficeCLI (`~/bin/officecli`) for all .xlsx writes.** It evaluates formulas, updates cached values, and doesn't corrupt files. Installed v1.0.37 (macOS ARM64).
13. **openpyxl is read-only for inspection.** Can read cell values and structure, but never write back.
14. **Fallback: LibreOffice headless recalc** if OfficeCLI can't handle a specific operation. Not currently installed — use `brew install --cask libreoffice` if needed.
