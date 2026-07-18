# Build

You implement the task in code yourself, in the current chat. No command layer, no build subagents. If there's a ready plan — work from it. If there's no plan — first sketch a short implementation plan yourself and execute it right away, if there's nothing unclear.

## Principles

- First understand the task and the existing code, then edit.
- Make a minimal scoped diff, strictly per the request.
- Follow `docs/ai/rules/project.md` for general invariants and `docs/ai/rules/coding-rules.md` for source / template code.
- Don't add dependencies, don't commit, and don't push without an explicit request.
- Don't do drive-by refactors.
- Prefer extending an existing pattern over introducing a new one.
- If the task starts to sprawl — stop, simplify the plan, or check with the user.

## Process

### 1. Clarification (mandatory gate)

Before the first edit, run the clarify gate per `docs/ai/skills/implementation-clarify.md` and **always print its result as one visible line** — this is not an optional internal step. Don't start code without that line.

The result is one of two things:

- a block of questions (if there's something unclear or a red flag);
- a line like `Clarification: no red flags → proceeding with defaults [X, Y]` (if everything is clear).

Before that, check yourself against the checklist:

- [ ] Scope and the main user flow are clear: what's in the task, what's out?
- [ ] Required UI states are defined: loading, error, empty, disabled, success?
- [ ] The data source and the DTO shape are clear?
- [ ] No "red flags" from `docs/ai/skills/implementation-clarify.md` (security, payments, race conditions, a new public API without a compatibility story)?

If even one item isn't settled by the task and isn't obvious from the code — print the block of questions.

Exception: if the user wrote "no questions", "defaults are fine", "proceed with reasonable assumptions" — skip the questions, but still print the `Clarification: …` line listing the defaults you took.

### 2. Plan before code

If the user already gave a plan or the task came in after `/plan` — follow that plan.

If there's no plan:

- For a simple task: keep a short internal plan and move to code.
- For a task touching 3+ files, a new flow, a public API, a data contract, security-sensitive logic, or notable trade-offs — write a short plan in chat before editing.

The short plan should include:

- affected files/modules;
- the order of changes;
- edge cases;
- checks.

### 3. Codebase review

Before editing:

- read the target files;
- find similar implementations;
- check the neighboring public-API entrypoints and consumers if the public API changes;
- check the data boundary if there's a backend/storage/URL/browser API;
- check UI states and i18n if the interface changes.

### 4. Implementation

Choose the order of steps by the task: first contracts and data, then logic and integrations, then UI, then tests and checks. Don't create layers and abstractions without need.

Before writing new non-trivial code, walk the ladder top-down and stop at the first step that applies:

1. **Is this even needed?** If a requirement doesn't follow from the task and is added "for the future" — don't write it (YAGNI).
2. **Already in the codebase?** Reuse it: a shared UI primitive, an existing hook/helper, a pattern from a neighboring module.
3. **Does a platform/language standard solve it?** A native browser API or a TS capability instead of your own wrapper.
4. **Does an already-installed dependency solve it?** The project's date library, an existing UI/data library, etc. Don't add a new dependency.
5. **Can it be shorter?** If the task is closed by a single expression — don't unfold it into an abstraction/layer.
6. **Only now** write the minimal implementation for the current case, without "just in case" generalizations.

The ladder comes _after_ understanding the task and reading the affected code (steps 1-3 above), not instead of them.

For security-sensitive and complex logic (validating amounts/inputs, formatters, parsing DTOs, race-condition guards) apply TDD: first a failing test for the expected behavior (red) → the minimum code to green (green) → refactor under green. The test here is an executable specification, not an after-the-fact check. For purely visual UI tasks (layout, styling, images) TDD isn't needed — verify by eye / with your component or e2e tooling.

Stories/visual states for UI components are as much a norm as unit tests for logic. A new presentational component gets its story/visual-state coverage; when adding a prop or visual state (variant, loading, empty, error, disabled, accessibility, etc.) add/update coverage for that state. You may skip stories only for purely container components with no visual state of their own.

## Project rules

Don't duplicate project rules in this skill. Use `docs/ai/rules/project.md` for general invariants, and `docs/ai/rules/coding-rules.md` for module boundaries, TypeScript, UI/i18n, React, styling, dates, and code style in source / template code.

## Tests and checks

What to cover with tests and how — `docs/ai/rules/testing.md`.

After substantive edits:

1. Run lint on the changed files.
2. Fix the errors you introduced.
3. For new/changed logic — unit tests; for UI components — story/visual-state coverage for the key states (see the "Implementation" step).
4. Run `<check>` and wait for the result.
5. If `<check>` fails because of your changes — fix it and rerun the relevant check.
6. If a check fails due to infrastructure or pre-existing problems — record this in the final response with a short explanation.

For visual verification, bring up your component or dev tooling **with the harness sandbox disabled** (`dangerouslyDisableSandbox`): from inside the sandbox they don't bind a port. The symptom is deceptive — the CLI prints `Port <N> is not available` even though `lsof -ti:<N>` shows the port free; via the preview tool the same cause shows up as `EPERM: operation not permitted, uv_cwd`. Get a component/story id from the tool's index rather than guessing it. Shut the server down after verifying.

## Final response format

Briefly:

- what was done;
- key files;
- which checks passed;
- if something couldn't be verified — why.
