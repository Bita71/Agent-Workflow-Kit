# Briefs for the night runner

How to write tasks for the night runner (see `night-runner/` and
`docs/ai/recipes/night-runner.md`). A brief is a `.md` file. The flow is two-phase:

1. `yarn night:plans` — the planner model builds a plan for each brief
   (`new/` → `planned/`). (These `yarn night*` commands belong to your runner setup;
   rename them to match yours.)
2. `yarn night` — the builder implements the plan → reviewers review → the builder
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
symlinked `node_modules` in the worktree will not pull it in), and large multi-day
features.

## Where and how to name

- A new brief goes in **`briefs/new/`**, named in kebab-case by the essence of the
  task, **without a date**: `fix-list-empty-state.md`.
- The file name → slug → branch `auto/<slug>`, worktree folder, and logs
  `logs/<slug>/`. The slug must be **stable** across the whole life cycle — so we do
  not put a date at the front.
- On the way to `done/`, the runner adds a timestamp to the name (`…T…Z-…`) for the
  archive — this does not affect the slug (it is stripped). An old date prefix
  (`2026-05-28-…`) is also stripped, but do not name new briefs that way.
- Template: `briefs/TEMPLATE.md`. Briefs are not committed (they are in
  `.gitignore`).

### Life cycle (folders)

`briefs/new/` → `briefs/planned/` (has a plan) → `briefs/in-progress/` (in flight) →
`briefs/done/`. The plan lives in `logs/<slug>/plan.md` and **survives until**
`yarn night:clean` (it is not deleted after implementation). There is no separate
`failed/` folder: an ordinary error rolls the brief back to its previous state
(`planned/` if there is a plan, otherwise `new/`). **Exception — the limit:** when it
hits a limit after all retries, the brief stays in `in-progress/` and is finished on
the next run (see below).

**Order and recovery.** `yarn night` takes briefs by priority: first `in-progress/`,
then `planned/`, then `new/`. If a run was cut off abruptly (kill, reboot), the brief
stays in `in-progress/` and on the next run is **finished first, on top of the prior
progress**: the `auto/<slug>` worktree, with its existing night commits and
uncommitted edits, is reused rather than recreated. If the worktree is gone or on a
different branch, the runner recreates it cleanly from `main`.

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
   of searching and narrows the scope. A module path, a component/hook name.
2. **Describe scope with bounds.** "Only the empty state, do not touch the loader" is
   better than "fix the screen".
3. **List the UI states** if the task is about a screen: loading / error / empty /
   disabled / success.
4. **Set a done-criterion** in terms of behavior, not implementation.
5. **Size it for one night.** If a task looks like "several features", split it into
   several briefs.
6. **Do not put secrets** (tokens, keys) in the brief — the agent sees it whole.

## Example: a good brief

```markdown
# Empty state for the list

## What's needed

When the backend returns an empty response, the list currently spins the loader
forever. It should show an empty state with text and an icon.

## Context

- List: the list module (component `ItemsList`).
- Data: the query in `model/`; the DTO can return an empty array.
- A similar empty state already exists in a sibling module — reuse the pattern.

## Constraints / don't do

- Do not touch the loader or error handling.
- No new dependencies. User-facing text goes through your i18n layer, not hardcoded.

## Done-criterion

- Empty array -> the empty state is visible (icon + text), the loader is hidden.
- `<check>` green.
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
- Review the diff (`git diff main...HEAD`), merge what you need into `main` yourself.
- The full pre-commit hook (`<check>`) fires on your commit to `main` — that is the
  final gate.

## Checklist before you drop a brief in

- [ ] A clear title and "What's needed".
- [ ] Anchors in the code (file/module), or an explicit note of what to search for.
- [ ] Scope bounds set (what not to touch).
- [ ] A done-criterion in terms of behavior.
- [ ] The task really fits one night and does not change dependencies.
- [ ] No secrets in the brief.
