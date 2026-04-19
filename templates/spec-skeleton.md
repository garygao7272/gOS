---
doc-type: product-spec
audience: <primary reader — one phrase, e.g. "Arx engineer implementing trade flow">
reader-output: <what the reader produces after reading — one phrase, e.g. "build-card for Phase 1 trade execution">
generated: <YYYY-MM-DD>
---

# <Spec Title>

*<Positioning sentence: what this document is + what the reader produces from it + why it exists now. One sentence. Do the three jobs explicitly.>*

**Covers:** <section a> · <section b> · <section c> · <section d>.

---

## 1. Boundaries

**IN SCOPE:** <what this spec answers>

**OUT OF SCOPE:** <adjacent questions handled elsewhere — name the other spec file>

**NEVER:** <what this spec refuses to cover — and why>

---

## 2. Atoms

<Irreducible units this spec operates on. Each atom traced to a cause, not precedent. Table form preferred.>

| Atom | Definition | Why irreducible |
|---|---|---|

---

## 3. Relations

<How atoms connect — mechanisms, causality, flows. "A causes B by mechanism X." Prose or flow diagram.>

---

## 4. Invariants

<Hard constraints (binary, AND-aggregated). Classify each as physical (immutable) or conventional (industry habit — candidate for relaxation under --innovate).>

| # | Invariant | Class | Failure mode if violated |
|---|---|---|---|

---

## 5. Degrees of freedom

<What can actually vary. For each: is this real agency, or phantom (labelled-as-choice but fixed by an upstream invariant)?>

| # | Degree of freedom | Real or phantom | Bounds |
|---|---|---|---|

---

## 6. Signals

<Observables that reveal state. Tag each: decisive (flips the call alone) or suggestive (accumulates).>

| Signal | Direction (for / against) | Class (decisive / suggestive) | Source / Evidence |
|---|---|---|---|

---

## 7. Rule

<How we combine / select / optimise. Form: "maximise X subject to invariants Y." Must be reproducible by a reader given the primitives above.>

---

## 8. Consequences

<If we commit to this rule, what becomes true downstream, what becomes harder, and what is foreclosed until revisited? Three bullets minimum.>

- **Downstream effect 1:** <concrete effect>
- **Downstream effect 2:** <concrete effect>
- **Downstream effect 3:** <concrete effect>

---

## Acceptance criteria (if applicable)

**Invariants (binary pass/fail, AND-aggregated — no partial credit):**

- [ ] <invariant 1>
- [ ] <invariant 2>

**Variants (continuous, weighted, trade-offs allowed):**

| Variant | Target | Weight | Notes |
|---|---|---|---|

---

## How to use this spec

<Action anchor — name the consumer, name the concrete output they produce after reading. 3–5 lines minimum. Not a glossary, not a changelog.>

---

## Appendix — version history and provenance

<All meta-content lives here: changelog, upstream research links, cycle history. Keep main body clean per the meta-content cap rule (≤5% of lines).>
