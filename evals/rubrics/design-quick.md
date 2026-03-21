# Eval Rubric: /design quick

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Anti-slop (20%) | 20 | Purple gradients, generic hero, AI aesthetic | Mostly original but some generic patterns | Distinctive, no AI clichés | Would be mistaken for a real designer's work |
| State coverage (25%) | 25 | Only happy path | Happy + one error state | All 5 states (loading, empty, error, populated, disabled) | All states + transitions between them described |
| Design system (20%) | 20 | Hardcoded colors/fonts | Some tokens used, some hardcoded | All values from design system | Introduces well-justified new tokens if needed |
| Mobile-first (15%) | 15 | Desktop layout on mobile | Responsive but desktop-first | 390x844 primary, readable | Touch targets 44pt+, safe areas, one-hand reachable |
| Interaction (20%) | 20 | Static mockup only | Some interactions noted | All interactive elements have states | Micro-interactions, feedback, delight moments |

## Scoring Rules

- Anti-slop: automatic 1 if purple gradient detected
- State coverage: count of 5 required states covered
- Design system: grep for hardcoded hex colors — each one reduces score
- Mobile-first: viewport assumptions checked
- Interaction: every button/link has hover/active/disabled states?

## Overall Score

Weighted average: `(antislop * 20 + states * 25 + system * 20 + mobile * 15 + interaction * 20) / 100`
