# Review Design

Find maintainability, boundary, usability, simplification, and performance
problems introduced or amplified by the changed scope. Do not duplicate proven
correctness/security defects.

## Scope

- Read config, active profiles, and applicable project rules.
- Review changed files and their nearest dependencies only.
- Propose simplification only when it reduces real complexity in scope.

## What to check

### Architecture and boundaries

- Ownership and dependency direction remain clear.
- Public contracts expose no unnecessary internals.
- Cross-boundary coupling and migration cost are proportionate to the task.
- The change follows repository patterns or gives a concrete reason to differ.

### Product and operator experience

- Applicable success, failure, progress, empty, and recovery behavior is clear.
- Errors and constraints are actionable for the relevant user/operator.
- Interface-specific checks come only from active profiles.

### Simplification

- No redundant wrapper, duplicated path, premature abstraction, dead branch, or
  unnecessary state.
- Apply Chesterton's Fence before proposing removal.

### Performance

- A required finding needs evidence or an obviously material risk.
- Check applicable hot paths, repeated I/O, avoidable round trips, unbounded work,
  allocation/resource lifetime, and caching invalidation.
- Language/framework-specific checks come from active profiles.

## Severity and format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [severity]
**File:** `path`
**Problem:** [gist]
**Why it hurts:** [boundary, UX, performance, maintenance]
**Suggestion:** [concrete action]
**Assessment:** risk [low/medium] | impact [high/medium/low] | effort [small/medium]
```

If clean: `No substantial design problems found`.
