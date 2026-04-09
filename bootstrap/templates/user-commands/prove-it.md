# Prove It Works (Boris Cherny Workflow)

You must PROVE that the changes you made actually work. Do not just claim they work.

## Verification Steps

1. **Diff check**: Show `git diff` of all changes. Explain each change and why it's correct.

2. **Run tests**: Execute all relevant tests. If tests fail, fix them before proceeding.

3. **Build check**: Run the build/compile step. Confirm zero errors and zero warnings.

4. **Manual verification**:
   - If there's a preview server, open it and verify visually
   - If there's an API, curl the endpoints and show the responses
   - If there's a CLI, run it with sample inputs and show output

5. **Edge case verification**: Test at least 2 edge cases specific to the change.

6. **Regression check**: Verify that existing functionality still works — run the full test suite, not just new tests.

## Output

Provide a verification report:
```
VERIFIED: [feature/fix name]
- Tests: PASS (X/Y passing)
- Build: PASS (0 errors, 0 warnings)
- Manual: PASS (describe what you checked)
- Edge cases: PASS (list what you tested)
- Regression: PASS (full suite green)
```

If ANY check fails, fix it before reporting. Do NOT report partial success.
