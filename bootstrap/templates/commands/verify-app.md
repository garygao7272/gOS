# Verify Arx App (Arx-Specific)

Comprehensive verification of the Arx mobile webapp after changes.

## Verification Checklist

### 1. Visual Check (390x844 viewport)
- [ ] Start preview server (`./serve.sh` or preview_start)
- [ ] Check all 8 tabs render correctly
- [ ] No overflow, no clipping, no broken layouts
- [ ] Design tokens match `:root` CSS variables
- [ ] Dark surfaces, correct opacity layers

### 2. Interaction Check
- [ ] Tab navigation works (all 8 tabs)
- [ ] Modals/sheets open and close
- [ ] Scroll behavior is smooth
- [ ] No console errors

### 3. Design System Compliance
- [ ] No hardcoded colors (all via CSS variables)
- [ ] No hardcoded fonts (all via design tokens)
- [ ] Spacing follows 4px/8px grid
- [ ] Typography hierarchy preserved

### 4. SOUL.md Compliance
- [ ] Information density matches spec
- [ ] Visual hierarchy is correct
- [ ] No unnecessary chrome or decoration

### 5. Version Check
- [ ] VERSION file is bumped
- [ ] CHANGELOG.md is updated
- [ ] Archive contains previous version

## Output
Report pass/fail for each section. Fix any failures before marking complete.
