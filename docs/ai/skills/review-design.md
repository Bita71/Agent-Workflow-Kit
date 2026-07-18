# Review Design

Look for code-design and product-design problems: maintainability, boundaries, UX, performance, and simplification. Don't duplicate correctness bugs.

## Scope

- Review only the changed files and their nearest dependencies.
- On a small diff, don't bloat the report.
- Propose simplification only within the diff, or when the diff amplifies an existing problem.

## What to check

First check the applicable project rules from `docs/ai/rules/project.md` and `docs/ai/rules/coding-rules.md`, if they relate to the changed diff. Don't duplicate the rules in full — report only the specific violations.

### Architecture and boundaries

- The code sits in the correct layer and module.
- The public API doesn't leak internal details and doesn't export the unnecessary.
- Cross-layer and cross-module links don't create hidden coupling.
- The props/hooks/DTO/query/mutation contracts can evolve without a large refactor.

### UX and product consistency

- The user sees clear states: loading, error, empty, disabled, success.
- Errors and constraints are explained, not silently breaking the flow.
- The UI doesn't diverge from the project's local patterns and components.
- For visual changes, ARIA/modal patterns aren't broken.

### Simplification

- Remove excess complexity, but apply Chesterton's Fence: first understand why the code was that way.
- Duplication, a wrapper for a wrapper's sake, excess effects/state, dead code, premature abstraction.
- Prefer a simple local solution over a new universal abstraction.

### Performance

- A performance finding as `Required` only with evidence or an obviously strong risk.
- Check request waterfalls, unstable query keys, excess refetches, heavy computations in render.
- In React, check excess rerenders, inline objects/functions in hot spots, keys in lists.

## Severity

- `Critical`: an architectural decision breaks security/data/core flow.
- `Required`: must be fixed before merge, otherwise a maintainability problem or a noticeable UX/performance risk appears.
- `Nit`: a small, pointed fix.
- `Optional`: a quality improvement, not mandatory now.
- `FYI`: context or future tech debt.

## Don't

- Don't propose a large refactor out of scope.
- Don't duplicate correctness/security findings.
- Don't reference project rules in full; point out the specific applicable violation.

## Format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [Critical / Required / Nit / Optional / FYI]

**File:** `path`
**Problem:** [the gist]
**Why it hurts:** [architecture / UX / performance / maintenance]
**Suggestion:** [concrete action]
**Assessment:** risk [low/medium] · impact [high/medium/low] · effort [small/medium]
```

If there are no substantial problems: `No substantial design problems found`.
