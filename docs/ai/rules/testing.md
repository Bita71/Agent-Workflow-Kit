# Testing Rules

Use the repository's configured test tools and only the active profile overlays.

## Principles

- Test observable behavior and contracts, not incidental implementation steps.
- Prioritize by the likelihood and cost of failure, not a universal coverage
  percentage.
- A test must be capable of failing for the defect it claims to cover.
- Keep tests deterministic: control time, randomness, concurrency, network, and
  external state at the narrowest useful boundary.
- Do not silently change unrelated behavior discovered while adding coverage.

## What to cover

- New or changed branching logic and invariants.
- Boundary mapping, validation, parsing, serialization, and error behavior.
- Compatibility and migration behavior when a public contract changes.
- Repeated, concurrent, partial, timeout, cancellation, and retry behavior when
  applicable.
- The regression path for every bug fix unless the repository cannot express it;
  document that limitation when it cannot.

## Test level

- Choose unit, integration, end-to-end, static, simulation, or manual verification
  by the behavior being proved and the project's existing tooling.
- Prefer the narrowest stable test that proves the requirement.
- Do not require UI, network, database, or browser testing for a task that does not
  involve those capabilities.
- Language/framework-specific naming, fixtures, mocks, and visual coverage come
  from active profiles and local project rules.

## Verification

- Run the smallest relevant checks while iterating.
- Finish with the configured `CHECK_COMMAND` unless it is `none` for a
  documentation-only repository.
- Record commands that could not run and the exact reason.
