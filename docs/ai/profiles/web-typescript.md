# Web TypeScript Profile

Activate only for a TypeScript web application. These are reusable defaults; the
repository's actual framework, test runner, component tooling, date/number
libraries, and directory conventions remain authoritative.

## Planning and implementation

- Identify the data source, transport/domain types, public exports, state owner,
  and UI consumers when the change crosses those boundaries.
- For a user-visible change, define applicable loading, error, empty, disabled,
  success, retry, and cancellation behavior before implementation.
- Order work by real dependencies: contracts/data mapping, behavior/state, UI,
  then focused tests and visual coverage. Do not create all of these layers when
  the task does not need them.
- Slice broad features vertically so each slice has usable behavior and a
  verification path; avoid layer-only milestones that cannot be exercised.
- Reuse existing components, hooks, query/mutation conventions, styling tokens,
  formatters, and test fixtures before adding a parallel primitive.

## TypeScript and data boundaries

- Do not add `any`, unsafe casts, or non-null assertions without a concrete
  guarantee. Prefer narrowing, validation, and typed boundary adapters.
- Preserve transport/domain types across mapping, state, and public APIs; do not
  silently discard nullability, units, enum cases, or error variants.
- Treat browser APIs, URLs, storage, backend responses, files, and user-provided
  data as untrusted until validated at the appropriate boundary.
- Test parsers and mappers with empty values, malformed input, extra fields,
  unsupported enum values, ambiguous numeric notation, and valid-prefix/junk-
  suffix cases when those inputs are accepted.

## React and state

- Keep state ownership explicit. Avoid duplicating derived state or synchronizing
  two sources of truth through effects.
- Check effect dependencies, updates during render, stale closures, cleanup,
  async races, repeated actions, and stable list keys.
- Keep branch-heavy calculations, parsing, and validation out of hook bodies when
  a nearby pure function makes the behavior independently testable. Hooks remain
  thin integration wrappers; do not extract trivial one-use expressions.
- Treat memoization as a measured optimization. Check unstable objects/functions
  only on proven or obvious hot paths.

## UI, accessibility, and text

- Route user-facing text through the project's i18n layer when one exists; test
  stable keys/parameters rather than translated prose where that is the local
  convention.
- Reuse the project's components and styling tokens. Do not introduce hardcoded
  design values or a second component vocabulary without a requirement.
- Preserve keyboard, focus, label, modal, and ARIA behavior when changing an
  interactive component.
- A new presentational component or visual state gets the repository's normal
  story/fixture/screenshot coverage when that tooling exists. Container-only
  components with no visual state do not need artificial stories.

## Testing

- Follow the repository's test naming, placement, fixture, and mocking
  conventions; do not impose a universal `*.test.ts` layout.
- Prefer the narrowest stable test: pure functions for calculations and
  validation, integration tests for component/data boundaries, and browser/e2e
  checks for behavior that unit tests cannot prove.
- Use fake timers and a fixed clock for time-dependent logic, then restore real
  timers in teardown. Cover timezone/period boundaries only when time behavior is
  in scope.
- For a bug fix, add a regression test that fails on the broken path when the
  repository can express it.
- E2E tests should prepare their own state through supported helpers rather than
  relying on a long-lived account or previous test order.
- Visual-only changes may use component/browser verification instead of forced
  unit-test TDD. Branchy validation, parsing, and state-transition logic should
  use an executable-specification loop when risk justifies it.

## Security and verification

For changed `.ts`, `.tsx`, `.js`, or `.jsx` files, use these only as discovery
queries; inspect every hit before reporting it:

```bash
rg -n 'dangerouslySetInnerHTML|innerHTML|eval\(|new Function\(|document\.write|javascript:' <changed-files>
rg -n 'apiKey|secretKey|privateKey|password|token' --case-sensitive <changed-files>
rg -n 'localStorage|sessionStorage|postMessage|window\.open|location\.href' <changed-files>
rg -n 'console\.(log|debug|warn|error)' <changed-files>
```

When a manifest or lockfile changes, use the ecosystem-aware dependency audit.
For visual verification, use the repository's component/dev tooling and record
environment limitations instead of guessing that a failed preview is a code bug.
