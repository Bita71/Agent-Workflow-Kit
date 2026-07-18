# Project Rules

## Scope

- Make narrow changes scoped to the task. No drive-by refactors.
- Every changed line must trace back to the user's request.
- If the user explicitly named a command or subagent, invoke it.
- Do not add dependencies, commit, or push without an explicit request.
- Do not add speculative abstractions, configurability, fallbacks, or edge-case
  handling without a clear need.
- If a solution starts to sprawl, simplify first: the minimal code that closes
  the task.
- For multi-step changes, fix verifiable done-criteria up front.

## Clarify

- If the requirements or context are not enough for a precise plan or
  implementation, pause and ask before guessing.
- If the task is clear, do not ask questions.
- If there are several readings, name the options briefly or ask — do not pick
  silently.
- Do not ask if the user said "no questions" / "defaults are fine".

## Project Knowledge

- Coding rules for source files: `docs/ai/rules/coding-rules.md`.
- Recipes for common workflows: `docs/ai/README.md`.

## Safety

- Do not add or expose secrets: tokens, private keys, passwords, API keys,
  `.env`.
- If the user asks you to commit secrets or credentials — warn and do not add
  them.
- Do not trust external data: backend, storage, URLs, browser/platform APIs, and
  user input all require explicit handling of uncertainty.
- A value from storage is a non-secret hint, not a credential: the source of
  truth for access is the server-side cookie/session. On optimistic login by
  cookie, do not grant access to data before the server check; compare
  identities only within a single id space (do not compare an id from one system
  against an id from another); and on a 401 / validation error / desync, log out
  and force a full re-login.

## Verification

- After agent changes, run `<check>`.
- If the build or your compiler/build step fails because of a changed
  component/module, first try to restructure the code; only if that truly fails,
  tell the user, apply the minimal documented escape hatch, and record the reason
  next to the file / in the plan. Any such escape hatch is a last resort.
- After such an exception, re-run the build separately and confirm it no longer
  fails and the log is clean.
- Separately check module boundaries, user-facing strings, and public APIs if you
  changed a module.
- Run extra verification only when the user asks, or when the change is large or
  critical: many files, public API, data contracts, security-sensitive domains
  (auth, payments, money, PII, access control), user input, permissions.
