# Clarifications before implementation

Close material ambiguity before it becomes an architectural, behavioral, or
irreversible decision.

## When to apply

Ask only when the answer cannot be discovered from the task, repository, config,
active profiles, or existing behavior and a wrong assumption would materially
change the result.

If the task is clear and there are no red flags, continue without questions. If
the user explicitly accepted reasonable defaults, use them only for conventional,
reversible implementation details.

## What to clarify

- **Scope and behavior:** required outcome, excluded work, compatibility, and done
  criteria.
- **Ownership and contracts:** affected module/layer, public interface, migration,
  and consumers.
- **Data and trust:** source, authority, validation, nullability/absence, failure,
  retry, idempotency, and concurrency where applicable.
- **User-visible decisions:** only when the task actually has an interface and
  several behavior/UX choices are equally valid.
- **Verification:** the behavior to prove and any environment limitation not
  resolved by `CHECK_COMMAND`.

Use active profiles for stack/domain-specific questions. Do not ask UI, DTO,
browser, database, or deployment questions when those capabilities are not part
of the task.

## Red flags: a question is mandatory

- A public contract changes and compatibility or migration expectations are
  unknown.
- An irreversible or destructive action has more than one plausible scope.
- A trust boundary or security-sensitive action lacks authority, validation, or
  failure behavior.
- A race, retry, repeated action, or partial failure exists but expected behavior
  is undefined.
- A user-visible fork has several valid outcomes and repository conventions do not
  resolve it.

## Visible result

If questions are required:

```markdown
Need to clarify:

- [question]
```

If no question is required:

```markdown
Clarification: no red flags -> proceeding with defaults [X, Y].
```

Silently skipping the gate is not allowed in build workflows.
