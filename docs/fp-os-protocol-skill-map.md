# FP-OS Protocol ↔ Skill Map

> `commands/gos.md` Phase 2.5 routes problems to protocols and verbs. This doc adds the skill binding that *executes* each protocol inside its verb.

| Protocol | gOS Verb(s) | Canonical Skill | Runs at |
|---|---|---|---|
| **Decision** (decision protocol) | `/think decide`, `/review gate` | `anthropic-skills:decision-prioritization` | 4-question gate inside `/think decide` |
| **Diagnosis** (diagnosis protocol) | `/review` (root-cause), `/build fix` | `engineering:debug` | 3-question pattern inside `/review` |
| **Design** (design protocol) | `/think discover`, `/design card` | `anthropic-skills:design-discovery` | 4-question lens inside `/think discover` |
| **Build** (build protocol) | `/build feature`, `/design ui` | `anthropic-skills:execution-planning` + `tdd-workflow` | 5-question pre-build inside `/build feature` |
| **Strategy** (strategy protocol) | `/think research`, `/simulate scenario` | `anthropic-skills:product-strategy` | 5-question lens inside `/think research` |
| **Innovation modifier** (innovation modifier) | `--innovate` on `/design`, `/build` | `anthropic-skills:brainstorming-ideation` | 2 moves layered on base protocol |
| **Runtime** (decompose→reinvent) | all verbs | `first-principles-decomposition` + `synthesis-distillation` | Phase 1 / Phase 2 of every verb |

## Rules

- Name the protocol in the intent line when invoking a verb. `/gos` Phase 2.5 does this by default.
- Skills run *inside* protocols. If a skill's advice violates a protocol invariant, protocol wins.
- Hybrid problems: pick the narrower protocol first; broaden only if it fails.

## Known gaps

- No `/think diagnose` verb — diagnosis is folded into `/review` (3-question pattern) and `/build fix`. Low-cost to add later if volume warrants.
- `--innovate` binds to `brainstorming-ideation` (divergent); the FP-OS two-move protocol (invariant-classify + atom-import) is more precise. Candidate: a gOS-local `fp-os-innovation` skill.
- The decompose→reinvent→loop runtime is implicit across verbs; never named as the stopping condition (one full pass produces no new atoms / invariants / boundary shifts).
