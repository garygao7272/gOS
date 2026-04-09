---
name: gos-rules
description: "gOS development rules -- coding style, testing, security, git workflow, performance, patterns, agent orchestration. Common rules with language-specific overrides for TypeScript, Python, Go, Swift, PHP."
---

# gOS Development Rules

## Common Rules

### Coding Style

**Immutability (CRITICAL):** ALWAYS create new objects, NEVER mutate existing ones. Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

**File Organization:** Many small files over few large files. 200-400 lines typical, 800 max. High cohesion, low coupling. Organize by feature/domain, not by type.

**Error Handling:** Handle errors explicitly at every level. User-friendly messages in UI-facing code. Detailed error context server-side. Never silently swallow errors.

**Input Validation:** Validate all user input at system boundaries. Use schema-based validation. Fail fast with clear error messages. Never trust external data.

**Code Quality Checklist:**
- Code is readable and well-named
- Functions are small (<50 lines), files focused (<800 lines)
- No deep nesting (>4 levels)
- Proper error handling, no hardcoded values
- Immutable patterns used throughout

### Testing Requirements

**Minimum Coverage: 80%**

Test Types (ALL required):
1. Unit Tests -- individual functions, utilities, components
2. Integration Tests -- API endpoints, database operations
3. E2E Tests -- critical user flows

**TDD Workflow (MANDATORY):**
1. Write test first (RED) -- run it, it should FAIL
2. Write minimal implementation (GREEN) -- run it, it should PASS
3. Refactor (IMPROVE) -- verify coverage 80%+

Use **tdd-guide** agent proactively for new features.

### Security

**Before ANY commit:**
- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated
- SQL injection prevention (parameterized queries)
- XSS prevention (sanitized HTML)
- CSRF protection enabled
- Authentication/authorization verified
- Rate limiting on all endpoints
- Error messages don't leak sensitive data

**Secret Management:** NEVER hardcode secrets. ALWAYS use environment variables or a secret manager. Validate required secrets at startup. Rotate any exposed secrets.

**Security Response:** If security issue found, STOP immediately. Use **security-reviewer** agent. Fix CRITICAL issues before continuing.

### Git Workflow

**Commit Format:**
```
<type>: <description>

<optional body>
```
Types: feat, fix, refactor, docs, test, chore, perf, ci

**PR Workflow:** Analyze full commit history, use `git diff [base-branch]...HEAD`, draft comprehensive summary, include test plan, push with `-u` flag if new branch.

### Performance & Model Selection

**Model Selection:**
- **Haiku 4.5** (90% of Sonnet, 3x savings): Lightweight agents, pair programming, worker agents
- **Sonnet 4.6** (Best coding model): Main dev work, orchestrating workflows, complex coding
- **Opus 4.5** (Deepest reasoning): Complex architecture, max reasoning, research/analysis

**Context Window:** Avoid last 20% for large-scale refactoring, multi-file features, complex debugging. Lower sensitivity: single-file edits, utility creation, docs, simple fixes.

**Extended Thinking:** Enabled by default (up to 31,999 tokens). Toggle: Option+T / Alt+T. For complex tasks: enable Plan Mode, use multiple critique rounds, use split role sub-agents.

**Build Troubleshooting:** Use **build-error-resolver** agent. Analyze errors, fix incrementally, verify after each fix.

### Development Workflow

**Feature Implementation Pipeline:**

0. **Research & Reuse** (mandatory before new implementation)
   - GitHub code search first: `gh search repos` and `gh search code`
   - Library docs second: Context7 or vendor docs
   - Exa only when first two are insufficient
   - Check package registries (npm, PyPI, crates.io) before writing utility code
   - Prefer adopting proven approaches over writing net-new code

1. **Plan First** -- Use **planner** agent. Generate planning docs (PRD, architecture, system_design, tech_doc, task_list).

2. **TDD Approach** -- Use **tdd-guide** agent. RED -> GREEN -> IMPROVE. Verify 80%+ coverage.

3. **Code Review** -- Use **code-reviewer** agent immediately after writing. Address CRITICAL and HIGH issues.

4. **Commit & Push** -- Detailed messages, conventional commits format.

### Patterns

**Skeleton Projects:** Search for battle-tested skeletons before implementing. Use parallel agents to evaluate options (security, extensibility, relevance, implementation planning). Clone best match as foundation.

**Repository Pattern:** Encapsulate data access behind a consistent interface (findAll, findById, create, update, delete). Business logic depends on the abstract interface, not storage.

**API Response Format:** Consistent envelope with success/status indicator, data payload (nullable on error), error message (nullable on success), metadata for pagination (total, page, limit).

### Agent Orchestration

**Available Agents:**

| Agent | Purpose |
|-------|---------|
| planner | Implementation planning |
| architect | System design |
| tdd-guide | Test-driven development |
| code-reviewer | Code review |
| security-reviewer | Security analysis |
| build-error-resolver | Fix build errors |
| e2e-runner | E2E testing |
| refactor-cleaner | Dead code cleanup |
| doc-updater | Documentation |

**Immediate Usage (no prompt needed):**
- Complex feature requests -> **planner**
- Code just written/modified -> **code-reviewer**
- Bug fix or new feature -> **tdd-guide**
- Architectural decision -> **architect**

**Parallel Execution:** ALWAYS use parallel Task execution for independent operations. Launch multiple agents simultaneously when tasks are independent.

**Multi-Perspective Analysis:** For complex problems, use split role sub-agents: factual reviewer, senior engineer, security expert, consistency reviewer, redundancy checker.

### Hooks

**Hook Types:**
- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

**Auto-Accept Permissions:** Enable for trusted plans, disable for exploratory work. Never use dangerously-skip-permissions. Configure `allowedTools` in `~/.claude.json`.

**TodoWrite Best Practices:** Track multi-step tasks, verify understanding, enable real-time steering, show granular steps. Reveals out-of-order steps, missing items, wrong granularity.

---

## Language-Specific Overrides

### TypeScript

**Types and Interfaces:**
- Add explicit types to exported functions, shared utilities, public class methods
- Let TS infer obvious local variable types
- Use `interface` for extensible object shapes; `type` for unions, intersections, mapped types
- Prefer string literal unions over `enum`
- Avoid `any` -- use `unknown` for untrusted input, then narrow safely
- Define React props with named `interface` or `type`; do not use `React.FC`

**Immutability:** Use spread operator for immutable updates. Mark parameters `Readonly<T>`.

**Error Handling:** async/await with try-catch. Narrow `unknown` errors safely. Use proper logging libraries, no `console.log` in production.

**Input Validation:** Use Zod for schema-based validation. Infer types from schemas with `z.infer<typeof schema>`.

**Patterns:**
- Typed `ApiResponse<T>` envelope with success, data, error, meta fields
- Custom hooks pattern (e.g., `useDebounce<T>`)
- Generic `Repository<T>` interface (findAll, findById, create, update, delete)

**Testing:** Use **Playwright** for E2E testing. Use **e2e-runner** agent.

**Hooks:** PostToolUse: Prettier (auto-format), `tsc` (type check), console.log warning. Stop: console.log audit on all modified files.

**Security:** Secrets via `process.env`. Validate presence at startup. Use **security-reviewer** for audits.

### Python

**Standards:** PEP 8 conventions. Type annotations on all function signatures.

**Immutability:** `@dataclass(frozen=True)` for immutable data. `NamedTuple` for simple value types.

**Formatting:** black (formatting), isort (imports), ruff (linting).

**Patterns:**
- `Protocol` classes for duck typing / repository interfaces
- `@dataclass` as DTOs for request/command objects
- Context managers for resource management
- Generators for lazy evaluation

**Testing:** pytest framework. `pytest --cov=src --cov-report=term-missing`. Use `pytest.mark` for categorization (unit, integration).

**Hooks:** PostToolUse: black/ruff (format), mypy/pyright (type check). Warn on `print()` statements.

**Security:** Secrets via `os.environ` with `python-dotenv`. Use **bandit** for static security analysis (`bandit -r src/`).

### Go

**Style:** gofmt and goimports are mandatory. Accept interfaces, return structs. Keep interfaces small (1-3 methods).

**Error Handling:** Always wrap errors with context: `fmt.Errorf("failed to X: %w", err)`. Go-idiomatic mutation with pointer receivers is preferred over strict immutability.

**Patterns:**
- Functional options: `type Option func(*Server)` with `WithPort(port int) Option`
- Small interfaces defined where used, not where implemented
- Constructor-based dependency injection: `NewUserService(repo, logger)`

**Testing:** Standard `go test` with table-driven tests. Always run with `-race` flag. `go test -cover ./...` for coverage.

**Hooks:** PostToolUse: gofmt/goimports, go vet, staticcheck.

**Security:** Secrets via `os.Getenv()` with fatal on missing. Use **gosec** (`gosec ./...`). Always use `context.Context` for timeout control with `defer cancel()`.

### Swift

**Style:** SwiftFormat for formatting, SwiftLint for enforcement. Follow Apple API Design Guidelines: clarity at point of use, omit needless words.

**Immutability:** Prefer `let` over `var`. Use `struct` with value semantics by default; `class` only for identity/reference semantics.

**Concurrency:** Swift 6 strict concurrency checking. `Sendable` value types for isolation boundaries. Actors for shared mutable state. Structured concurrency (`async let`, `TaskGroup`) over unstructured `Task {}`.

**Error Handling:** Typed throws (Swift 6+) with pattern matching.

**Patterns:**
- Protocol-oriented design with small, focused protocols and protocol extensions
- Enums with associated values for state modeling (`LoadState<T>`)
- Actor pattern for shared mutable state (replaces locks/dispatch queues)
- DI via protocol injection with default parameters

**Testing:** Swift Testing framework (`import Testing`). `@Test` and `#expect`. Fresh instance per test (init/deinit). Parameterized tests with `arguments:`. Coverage: `swift test --enable-code-coverage`.

**Hooks:** PostToolUse: SwiftFormat, SwiftLint, `swift build`. Flag `print()` statements.

**Security:** Keychain Services for sensitive data (never UserDefaults). Environment variables or `.xcconfig` for build-time secrets. App Transport Security enforced. Certificate pinning for critical endpoints. Validate URLs, deep links, pasteboard data.

### PHP

**Standards:** PSR-12 formatting. `declare(strict_types=1)` in application code. Scalar type hints, return types, typed properties everywhere.

**Immutability:** Immutable DTOs and value objects for service boundaries. `readonly` properties or immutable constructors. Promote business-critical arrays to explicit classes.

**Formatting:** PHP-CS-Fixer or Laravel Pint. PHPStan or Psalm for static analysis.

**Error Handling:** Throw exceptions for exceptional states; avoid returning `false`/`null` as hidden error channels. Convert input to validated DTOs before domain logic.

**Patterns:**
- Thin controllers (auth, validation, serialization, status codes) with explicit services for business rules
- DTOs and value objects replace associative arrays for requests, commands, API payloads
- DI via interfaces/narrow contracts, not framework globals; constructor injection
- Wrap third-party SDKs behind adapters

**Testing:** PHPUnit (default) or Pest. `vendor/bin/phpunit --coverage-text`. Prefer pcov or Xdebug in CI. Separate fast unit tests from integration tests. Factory/builders for fixtures.

**Hooks:** PostToolUse: Pint/PHP-CS-Fixer, PHPStan/Psalm, PHPUnit/Pest. Warn on `var_dump`, `dd`, `dump`, `die()`. Warn on raw SQL or disabled CSRF/session protections.

**Security:**
- Validate request input at framework boundary (FormRequest, Symfony Validator, DTO validation)
- Escape output by default; raw HTML must be justified
- Prepared statements for all dynamic queries (PDO, Doctrine, Eloquent)
- No string-building SQL in controllers/views; scope mass-assignment carefully
- Secrets from env or secret manager, never committed config
- `composer audit` in CI; pin major versions; remove abandoned packages
- `password_hash()`/`password_verify()` for passwords; regenerate session IDs after auth; enforce CSRF
