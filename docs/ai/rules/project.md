# Project Rules

## Scope

- Make narrow changes scoped to the task. No drive-by refactors.
- Every changed line must trace back to the user's request.
- If the user explicitly named a command or subagent, invoke it.
- Do not add dependencies, commit, or push without an explicit request.
- Do not add speculative abstractions, configurability, fallbacks, or edge-case
  handling without a clear need.
- If a solution starts to sprawl, simplify first: the minimal change that closes
  the task.
- For multi-step changes, define verifiable done criteria up front.

## Clarify

- If the requirements or context are not enough for a precise decision, pause and
  ask before guessing.
- If the task is clear, do not ask questions.
- If there are several materially different readings, name them briefly or ask;
  do not pick silently.
- Do not ask if the user explicitly accepted reasonable defaults and no mandatory
  risk question remains.

## Project knowledge

- Read `.agent-workflow-kit/config.conf` before applying a workflow.
- Load `docs/ai/profiles/core.md` and only the additional profiles listed in
  `PROFILES`.
- Repository-specific coding rules live in `docs/ai/rules/coding-rules.md`.
- Workflow and recipe inventory lives in `docs/ai/README.md`.

## Safety

- Do not add or expose secrets: tokens, private keys, passwords, API keys, or
  populated environment files.
- If the user asks to commit credentials, warn and do not add them.
- Treat data outside the current trusted boundary as uncertain. Identify its
  source, validation, failure behavior, and authority before relying on it.
- Apply authentication, payments, personal-data, and other domain policies only
  when an active profile or repository rule defines them.

## Verification

- After substantive agent changes, run the configured `CHECK_COMMAND` unless it is
  explicitly `none` for a documentation-only repository.
- If a compiler/build step fails because of a changed component or module, first
  restructure the change. Use a documented escape hatch only as a last resort and
  record the reason.
- After an exception, rerun the affected build/check separately and confirm that
  the relevant log is clean.
- Check affected boundaries, user-visible behavior, and public contracts when a
  module changes.
- Run extra verification when requested or when the change is broad, public,
  irreversible, security-sensitive, or crosses a trust boundary.
