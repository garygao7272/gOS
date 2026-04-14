# Assumption Log — {slug}

> Every decision made during build that WASN'T explicitly covered by the contract.
> `/gos save` ingests these as input for the next `/think spec` cycle.
> INV-G07 enforcement.

**Contract:** `contract.md`
**Session:** {date}

## Format

Each assumption:
- Why it was needed (what the spec didn't cover)
- What was chosen
- Why this choice (brief rationale)
- Reversibility (cheap / medium / expensive to revisit)
- Tag for next `/think spec` cycle

## Assumptions

### ASSUMPTION-001

**Context:** The spec doesn't define behavior when [X happens].

**Chose:** [What was implemented]

**Rationale:** [Why this choice over alternatives]

**Reversibility:** cheap | medium | expensive

**Tag:** needs-spec-decision | edge-case-addition | api-behavior-gap

---

### ASSUMPTION-002

**Context:** ...

**Chose:** ...

**Rationale:** ...

**Reversibility:** ...

**Tag:** ...

---

## Post-build review

Gary reviews assumptions at `/gos save`. Each one either:
- **Promoted:** becomes a spec addition (added to the source spec)
- **Reverted:** implementation rolled back, spec updated with explicit NOT
- **Accepted:** one-off exception, no spec change

| ID | Disposition | Spec updated? |
|---|---|---|
| ASSUMPTION-001 | Pending | — |
