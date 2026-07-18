# Testing Rules

What and how to test in source. Infrastructure: your unit test runner (fast,
isolated logic), your e2e tooling (against a test environment), and your
component/visual tooling for UI states.

## Principles

- Test **behavior, not implementation**: assert on the result/contract, not on
  internal steps. A test that breaks on a refactor with no behavior change is a
  bad test.
- Prioritize by risk (money / security / parsing), not by completeness. Do not
  chase 100% coverage (aim for roughly ~70% of logic branches).
- A test must be able to **fail**: before you ship, mentally (and for money logic,
  actually) inject a bug into the covered branch and confirm the test goes red. A
  change-detector (a snapshot of the current implementation with no check of
  meaning) is not a test.

## What to cover with unit tests

- Pure business logic: calculations, validators, formatters, parsing, DTO mapping.
- Mandatory — money and security: amounts, fees, limits, rates, auth/passcode
  branches, sanitization of external input (query params, deep links, untrusted
  entry parameters).
- For new/changed logic of this kind, the test is part of the task, not optional
  (TDD approach).

## How to write

- Put the test next to the module: `foo.ts` → `foo.test.ts`.
- `describe` is the function name.
- Mock data: reuse the exported API-layer mocks, or build a minimal typed object
  in the test.
- Mock user-facing string lookups (your i18n layer) with a function that returns
  the key (plus interpolation if needed): assert on keys, not on translations.
- Logic that depends on "now" — use fake timers and a fixed system time; do not
  forget to restore real timers in teardown.
- Compare decimal/money values via their string form (`.toString()` /
  `.toFixed()`), not whole objects.
- A test pins current behavior. Do not silently fix a bug found while writing
  coverage: mark a `TODO` in the test/code and split it into a separate change.
  Once the fix is approved (review), update the tests to the new behavior and drop
  the `TODO`.

## Mandatory edge cases

- **Money**: `0`, negatives, `NaN` / invalid strings, `undefined` price/limits,
  rounding direction (up/down/ceil/floor), inclusivity of min/max bounds,
  `fee > balance`, "config max = 0 → no limit".
- **Parsing untrusted input** (query / deep link / entry parameters): empty
  string, garbage (`1a5`), scientific notation (`1e5` — decimal libraries parse it
  as a number), extra parameters, invalid address/color, junk suffix after a valid
  prefix.
- **Dates / timezones**: month boundaries, UTC at the edge of periods, missing
  field → fallback.
- **Auth / passcode**: no token, user cancellation, platform error, repeated call
  (race).

## Logic in hooks

Do not lock money calculations and branchy logic inside a hook body: extract them
into a pure function nearby (`model/calc*.ts`, `model/validators.ts`, `libs/*`) and
test that. The hook stays a thin wrapper (data from query hooks → function call).
Testability is achieved by extraction, not by rendering.

## UI

- UI states are covered by your component/visual tooling, not unit tests: a new
  presentational component gets a story/fixture, and a new visual state gets its
  own story.
- Visual snapshots run through your component tooling.

## E2E

- New UI specs go under your e2e suite; mark stable, fast ones so a subset runs in
  CI by default.
- E2E tests hit a real test environment: do not rely on account state — prepare
  data through API helpers.

## Verification

- The unit test command is part of `<check>` and is mandatory after substantive
  changes.
