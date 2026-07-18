# Briefs for the night runner

How to write tasks for the night runner (see `night-runner/` and
`docs/ai/recipes/night-runner.md`). A brief is a `.md` file. The flow is two-phase:

1. `RUNNER_PLAN_COMMAND` — the planner model builds a plan for each brief
   (`new/` → `planned/`).
2. `RUNNER_EXEC_COMMAND` — the builder implements the plan → reviewers review → the builder
   fixes (`planned/` → `done/`).

Between the phases, **you read the plan and edit the brief** if something is off.

The key idea: **the agent cannot ask you a question live.** So the planner is told
to write a "Questions and assumptions" section into the plan — **as many** clarifying
questions and explicit assumptions as possible that it will adopt in the absence of
an answer. Your job when reviewing the plan is to run through that section and fix
the brief (or the plan itself) wherever an assumption is wrong. The more precise the
brief, the fewer wrong assumptions.

## When to use

- Tech debt and pointed one-night tasks: refactor a module, cleanup, a small
  feature, missing UI states, tests, renames, string fixes.
- Several independent tasks — each its own file; the runner takes them one at a time.

**Do not use** for: tasks without a clear done-criterion, investigations ("figure out
why it is slow"), tasks that change dependencies (a manifest/lock change — a
reused or symlinked dependency directory may not reflect it), and large multi-day
features.

## Where and how to name

- A new brief goes in **`briefs/new/`**, named in kebab-case by the essence of the
  task, **without a date**: `fix-list-empty-state.md`.
- The file name → slug → branch `auto/<slug>`, worktree folder, and logs
  `logs/<slug>/`. The slug must be **stable** across the whole life cycle — so we do
  not put a date at the front.
- On the way to `done/`, the runner adds a timestamp to the name (`…T…Z-…`) for the
  archive — this does not affect the slug (it is stripped). An old date prefix
(`YYYY-MM-DD-…`) may also be stripped by an implementation, but do not name new
briefs that way.
- Template: `briefs/TEMPLATE.md`. Briefs are not committed (they are in
  `.gitignore`).

### Life cycle (folders)

`briefs/new/` → `briefs/planned/` (has a plan) → `briefs/in-progress/` (in flight) →
`briefs/done/`. The plan lives in `logs/<slug>/plan.md` and **survives until**
`RUNNER_CLEAN_COMMAND` (it is not deleted after implementation). There is no separate
`failed/` folder: an ordinary error rolls the brief back to its previous state
(`planned/` if there is a plan, otherwise `new/`). **Exception — the limit:** when it
hits a limit after all retries, the brief stays in `in-progress/` and is finished on
the next run (see below).

**Order and recovery.** `RUNNER_EXEC_COMMAND` takes briefs by priority: first `in-progress/`,
then `planned/`, then `new/`. If a run was cut off abruptly (kill, reboot), the brief
stays in `in-progress/` and on the next run is **finished first, on top of the prior
progress**: the `auto/<slug>` worktree, with its existing night commits and
uncommitted edits, is reused rather than recreated. If the worktree is gone or on a
different branch, the runner recreates it cleanly from the resolved `BASE_REF`.

## Brief structure

| Section                 | Required | What to write                                              |
| ----------------------- | -------- | --------------------------------------------------------- |
| Title                   | yes      | The gist in one line.                                     |
| What's needed           | yes      | The problem and desired result, in your own words.        |
| Context                 | ideally  | Where in the code: files, modules, which layer, what to look at. |
| Constraints / don't do  | ideally  | What not to touch, which approaches are forbidden, scope bounds. |
| Done-criterion          | ideally  | How to know it's done (behavior, tests).                  |

Context and criterion are formally optional, but they are exactly what separates a
good autonomous result from "hit or miss".

## How to write a good brief

1. **Give anchors in the code.** A path to a file/module saves the agent half a night
   of searching and narrows the scope. Use a module path, symbol, or entrypoint.
2. **Describe scope with bounds.** "Only the empty state, do not touch the loader" is
   better than "fix the screen".
3. **List applicable states and failures.** Use interface-specific states only when
   an active profile and the task make them relevant.
4. **Set a done-criterion** in terms of behavior, not implementation.
5. **Size it for one night.** If a task looks like "several features", split it into
   several briefs.
6. **Do not put secrets** (tokens, keys) in the brief — the agent sees it whole.

## Example: a good brief

```markdown
# Reject malformed import records

## What's needed

The importer currently accepts a record with a missing identifier and fails later.
It should reject that record at the parser boundary with the existing error type.

## Context

- Parser: `src/import/parse-record.*`.
- Caller: `src/import/run-import.*` handles the existing parse error.
- A neighboring parser already validates its required identifier.

## Constraints / don't do

- Do not change the public error contract or unrelated fields.
- No new dependencies; follow active profiles and project rules.

## Done-criterion

- Missing identifier returns the existing parse error at the boundary.
- Valid records behave unchanged.
- `CHECK_COMMAND` is green.
```

## Example: a bad brief (do not do this)

```markdown
# Fix the list

Something is off with the list, take a look and fix it however is best.
```

Why it's bad: no scope, no files, no criterion. The agent will make up the task
itself and most likely miss the target — and it cannot ask.

## After a run

- Plan and review reports: `logs/<slug>/`.
- Changes: the worktree `../night-worktrees/<slug>`, branch `auto/<slug>`.
- Review the diff (`git diff "$BASE_REF"...HEAD`), then apply what you need into
  the base checkout yourself.
- The full pre-commit hook (`CHECK_COMMAND`) fires on your base-checkout commit - that is the
  final gate.

## Checklist before you drop a brief in

- [ ] A clear title and "What's needed".
- [ ] Anchors in the code (file/module), or an explicit note of what to search for.
- [ ] Scope bounds set (what not to touch).
- [ ] A done-criterion in terms of behavior.
- [ ] The task really fits one night and does not change dependencies.
- [ ] No secrets in the brief.
