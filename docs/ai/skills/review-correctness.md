# Review Correctness

Look for real behavior defects. Don't review style and architecture unless it leads to a bug.

## Scope

- Review only the changed files and the related code paths.
- Use the diff as the source of truth; read surrounding code only to understand behavior.
- Don't find problems in unchanged code, except where the new diff clearly activates an old bug.

## What to check

- Applicable project rules from `docs/ai/rules/project.md` and `docs/ai/rules/coding-rules.md`, if breaking them can lead to a bug, regression, or wrong behavior.
- Task conformance: the code does exactly what's claimed.
- Edge cases: empty data, `null`, `undefined`, network errors, timeouts, repeated actions.
- Data boundary: backend/storage/URL/browser API are not treated as trusted.
- State and async: race conditions, stale closures, floating promises, cleanup after unmount.
- React: wrong deps, state updates in render, unnecessary syncing via effects, missing loading/error/empty states.
- Type safety: new `any`, dangerous `as`, non-null assertions without a guarantee, loss of the DTO type.
- Error handling: silent failures, an empty `catch`, the user gets no feedback on an error.
- Domain: money, limits, currencies, formats, access control — security-sensitive domains (auth, payments, money, PII).
- Tests: important new behavior without a test or a manual check.

## Security baseline

Flag only obvious security bugs if they're visible in the diff: XSS, unsafe URL, secrets in logs, user input without validation, storing auth/session data in an insecure place. Deep security review is done by `skill-review-security`.

## Severity

- `Critical`: security/data loss/broken core flow.
- `Required`: bug, regression, incorrect edge case, missing validation.
- `Nit`: a small fix that genuinely reduces the risk of an error.
- `Optional`: an improvement that doesn't block merge.
- `FYI`: an observation with no required action.

## Don't

- Don't duplicate architecture, readability, simplification, and performance without a bug — that's `skill-review-design`.
- Don't rewrite project rules into the report; point out only the specific applicable violation in the diff.
- Don't report matters of taste.
- Don't speculate: a finding is needed only when there's a clear code path.

## Format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [Critical / Required / Nit / Optional / FYI]

**File:** `path`
**Problem:** [what will break]
**Evidence:** [line/diff fragment or code path]
**Fix:** [concrete fix]
```

If there are no problems: `No critical correctness problems found`.
