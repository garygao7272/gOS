# Spec-First Planning (Boris Cherny Workflow)

You are now in SPEC MODE. Do NOT write any code. Only read, analyze, and plan.

## Instructions

1. **Understand the request**: Re-read the user's request carefully. Ask clarifying questions if anything is ambiguous.

2. **Explore the codebase**: Read all relevant files, understand the current architecture, identify dependencies and constraints.

3. **Create a detailed spec** with these sections:

### Spec Output Format

```markdown
## Goal
One-sentence summary of what we're building/changing.

## Current State
- What exists today (files, components, patterns)
- Key constraints and dependencies

## Proposed Changes
For each file/component:
- [ ] What changes and why
- [ ] New files needed (if any)
- [ ] Files to modify

## Edge Cases & Risks
- What could go wrong
- What assumptions are we making

## Verification Plan
- How we'll know it works
- What to test (manual and automated)

## Open Questions
- Anything that needs the user's input before proceeding
```

4. **Present the spec** and wait for the user to review, annotate, and approve before any implementation begins.

Do NOT proceed to implementation until the user explicitly approves the spec.
