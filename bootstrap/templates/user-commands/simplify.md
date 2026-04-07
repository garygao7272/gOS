# Code Simplifier (Boris Cherny Workflow)

Review ALL code that was just written or modified in this session. Act as a senior engineer doing a simplification pass.

## Checklist

1. **Dead code**: Remove anything unused — variables, imports, functions, commented-out blocks
2. **Duplication**: Extract repeated logic into shared helpers (only if used 3+ times)
3. **Complexity**: Flatten nested conditionals, simplify boolean expressions, reduce indirection
4. **Naming**: Rename anything unclear — a reader should understand without comments
5. **Over-engineering**: Remove abstractions that serve only one call site, remove feature flags for shipped features, remove unnecessary config
6. **File size**: If any file exceeds 400 lines, consider splitting by responsibility
7. **Immutability**: Replace mutations with new-object patterns where possible

## Rules

- Make the MINIMUM changes needed to simplify
- Do NOT add features, refactor architecture, or change behavior
- Do NOT add comments, docstrings, or type annotations unless they fix a bug
- Every change must preserve existing behavior exactly
- Show a summary of what you simplified and why
