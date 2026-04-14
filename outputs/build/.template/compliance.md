# Compliance Matrix — {slug}

> Written when build completes. Maps each contract item to shipped code.
> `/ship` reads this; ⚠️ or ❌ rows block.

**Contract:** `contract.md`
**Diff:** `git diff {base}...HEAD`
**Verified at:** {ISO-8601}

## Definition-of-Done items

| DoD Item | File(s) | Function / Lines | Status | Notes |
|---|---|---|---|---|
| [Item 1 from contract] | path/to/file.ts | funcName() L20–48 | ✅ | — |
| [Item 2 from contract] | path/to/other.ts | handleX() L10–25 | ⚠️ | Partial — edge case EC-2 not yet handled |
| [Item 3 from contract] | — | — | ❌ | Not implemented |

## OUT OF SCOPE — confirmed not touched

| Item | Evidence |
|---|---|
| [Item from contract] | `grep -r "X" apps/` returned 0 new matches |

## NEVER — confirmed not violated

| Prohibition | Evidence |
|---|---|
| [Prohibition from contract] | [How you verified — e.g., "no spec files in diff: `git diff --stat` shows 0 specs/"] |

## Undeclared changes (code NOT in contract)

List any behavior in the diff that wasn't explicitly in Definition-of-Done. These either:
- Should be retroactively added to the contract (legitimate)
- Indicate scope creep (should be reverted)
- Indicate bug-fix along the way (log in `assumptions.md`)

- [None] OR:
- [file:line — description]

## Verdict

**Status:** COMPLETE | PARTIAL | BLOCKED
- If PARTIAL: list remaining DoD items, decide in chat before /ship
- If BLOCKED: revert or re-scope before proceeding
