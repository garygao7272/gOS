---
name: financial-modeling
description: Excel/XLSX financial modeling with formula evaluation. Auto-activates on .xlsx files. Uses OfficeCLI instead of openpyxl.
paths: "*.xlsx,*.xls"
---

# Financial Modeling Skill — OfficeCLI-Powered

## Critical Rule: NEVER Use openpyxl for Writing

openpyxl silently corrupts complex Excel files:
- Strips macros, named ranges, complex conditional formatting
- `delete_rows()` does NOT update formula references in the same sheet
- Cannot evaluate formulas (only reads stale cached values)
- See: anthropics/claude-code#22044

**openpyxl is READ-ONLY for inspection. All writes go through OfficeCLI.**

## Tool: OfficeCLI

Binary: `~/bin/officecli` (v1.0.37, macOS ARM64)
Docs: https://github.com/iOfficeAI/OfficeCLI

### Core Commands

```bash
# Create
officecli create output.xlsx

# Read cell/range
officecli get file.xlsx '/Sheet1/A1'
officecli get file.xlsx '/Sheet1/A1:D20'

# Write value
officecli set file.xlsx '/Sheet1/A1' --prop value=100

# Write formula (auto-evaluated, cachedValue updated)
officecli set file.xlsx '/Sheet1/A3' --prop formula='=A1+A2'

# View full sheet
officecli view file.xlsx table        # table view
officecli view file.xlsx tree         # tree structure
officecli get file.xlsx '/Sheet1'     # full sheet

# Batch operations (single open/save cycle — faster)
officecli batch file.xlsx '[
  {"command":"set","path":"/Sheet1/A1","props":{"value":"100"}},
  {"command":"set","path":"/Sheet1/A2","props":{"value":"200"}},
  {"command":"set","path":"/Sheet1/A3","props":{"formula":"=A1+A2"}}
]'

# Import CSV into sheet
officecli import file.xlsx '/Sheet1/A1' data.csv

# List sheets
officecli get file.xlsx '/'
```

### Path Syntax

- `/SheetName/A1` — single cell
- `/SheetName/A1:D20` — range
- `/SheetName/row[3]` — entire row
- `/SheetName/col[B]` — entire column
- `/` — workbook root (lists sheets)

## Financial Modeling Rules

From Gary's feedback (memory/feedback_financial_modeling_v2.md):

1. **Every cell except inputs must be a formula.** No hardcoded outcomes. Gary checks this.
2. **Prices/amounts use Decimal or integer base units.** Never float.
3. **ARPU is uniform across scenarios.** Only growth and churn vary.
4. **Peak Burn = MIN(cumulative P&L) formula,** not hardcoded.
5. **Monthly Breakeven = sustained 3+ consecutive positive months,** not first blip.
6. **Capital = Peak Burn × 1.20.** Formula-driven from actuals.
7. **Growth rates must be at or below BasedApp's 32.6%.** Defensible.
8. **MAU FY1 Total = end-of-period value (M12), not SUM.** Revenue/cost FY1 = SUM.
9. **Marketing: Valen M1-12 exact values, then cap at % of revenue M13+.**
10. **Referral decay at M12** (not M18 or M24).

## Precision Workflow (MANDATORY for Financial Models)

Two tools, two roles:
- **OfficeCLI** (`~/bin/officecli`) = fast read/write/edit (the hands). 150+ functions, auto-evaluates.
- **LibreOffice headless** (`soffice`) = full recalculation (the auditor). ~500 functions, near-Excel parity.

```
1. INSPECT    — officecli get → read current structure, formulas, cached values
2. PLAN       — identify cells to change, trace formula dependencies
3. EDIT       — officecli batch --commands '[...]' → write all changes in one save cycle
4. VERIFY     — officecli get → confirm formulas evaluate correctly
5. RECALCULATE — soffice --headless → force full recalc for cross-sheet + complex formulas
6. VALIDATE   — officecli get on recalculated file → confirm all values match expectations
7. AUDIT      — scan for hardcoded cells that should be formulas
```

**When to use LibreOffice recalc (step 5):**
- Cross-sheet references (e.g., `=Base!C20` from Optimistic sheet)
- Complex nested formulas (IF chains, SUMPRODUCT, INDEX/MATCH)
- After bulk edits (10+ cells changed)
- Before presenting to Gary (final verification)

**When OfficeCLI alone is sufficient:**
- Reading/inspecting a model
- Single cell edits with simple formulas
- Quick value updates to inputs

### LibreOffice Recalc Command

```bash
# Force recalculate and save (creates output in specified dir)
mkdir -p /tmp/lo_recalc && soffice --headless --calc --convert-to xlsx file.xlsx --outdir /tmp/lo_recalc/

# Then copy back
cp /tmp/lo_recalc/file.xlsx ./file.xlsx
```

### Batch Edit Example

```bash
officecli batch model.xlsx --commands '[
  {"command":"set","path":"/Base/C15","props":{"value":"300"}},
  {"command":"set","path":"/Base/C20","props":{"formula":"=SUM(C15:C19)"}},
  {"command":"set","path":"/Base/D30","props":{"formula":"=MIN(D2:D29)"}}
]'
```

## gOS Core Tool Integration

This skill is part of gOS's core toolbox. Any gOS verb that touches .xlsx files MUST use this workflow:
- `/think research` with financial data → use officecli to read source models
- `/build` financial features → use officecli to create/edit projection models
- `/review` financial models → use officecli to inspect + soffice to verify
- `/gos` conductor goals involving spreadsheets → auto-load this skill
