# Night Runner

An unattended, two-phase batch pipeline that turns a folder of task **briefs**
into reviewed branches while you sleep. You write briefs, the runner plans them,
implements them, reviews them, and fixes blocking findings — each task in its own
isolated git worktree, never touching `main`.

The kit ships this as a **pattern + config templates**, not runnable code: the
orchestration is deliberately thin and maps 1:1 onto the same agents, skills, and
CLI calls the rest of the kit already defines (`docs/ai/agents/cli.md`,
`docs/ai/skills/plan.md`, `docs/ai/skills/build.md`, the review skills). Templates
live in `night-runner/` (`sandbox.settings.json`, `briefs/TEMPLATE.md`). Wire the
loop to your task runner of choice (a small Node/TS script, a shell loop, a Make
target). How to *write* good briefs: `docs/ai/recipes/night-runner-briefs.md`.

## Why two phases

An unattended agent **cannot ask you a question mid-run**. So planning is split
from building, with you in the middle:

1. **Plan** — a planner model builds a self-contained plan per brief. The plan
   MUST contain a **"Questions and assumptions"** section listing as many
   clarifying questions and explicit assumptions as possible.
2. **You read the plans** and fix any brief whose assumptions are wrong. The more
   precise the brief, the fewer wrong assumptions leak into the build.
3. **Build + review + fix** — a strong builder implements the plan, correctness
   and design reviewers run over the frozen commit, and the builder fixes any
   Critical/Required findings, looping until clean or a round limit.

The whole runner is the same `produce → verify → fix → repeat` loop as
`/symphony`, minus the human gates — the plan-review step is your only gate.

## Roles (map to the kit)

| Step        | Actor                    | Follows                                     |
| ----------- | ------------------------ | ------------------------------------------- |
| Plan        | planner model (Codex)    | `docs/ai/skills/plan.md`                    |
| Build / Fix | strong builder (Claude)  | `docs/ai/skills/build.md`                   |
| Correctness | reviewer (Codex)         | `docs/ai/skills/review-correctness.md`      |
| Design      | reviewer (Claude)        | `docs/ai/skills/review-design.md`           |

Canonical CLI invocations for all of these: `docs/ai/agents/cli.md`.

## Brief lifecycle (folders)

```text
briefs/new/  →  briefs/planned/  →  briefs/in-progress/  →  briefs/done/
                                                         ↘  briefs/manual-review/
```

- The brief filename → `slug` → branch `auto/<slug>`, worktree dir, and
  `logs/<slug>/`. Keep the slug **stable** for the whole lifecycle — do **not**
  put a date at the front of the filename.
- The plan lives at `logs/<slug>/plan.md` and survives until you clean up.
- There is **no `failed/` folder.** An ordinary failure **rolls the brief back**
  to its previous state (`planned/` if a plan exists, else `new/`) and the run
  moves on. Within a single run a rolled-back brief is not retried, so the loop
  can't spin.
- **Round-limit exception:** if the review→fix loop hits its round cap
  (`MAX_ROUNDS`, default 3) with blocking findings still open, the brief goes to
  `manual-review/` instead of `done/`.

## Priority and recovery

The build phase takes briefs in priority order: **`in-progress/` first, then
`planned/`, then `new/`** (a `new/` brief is planned on the fly).

If a run is interrupted — rate limit, Ctrl-C, panic, kill, reboot — the brief
stays in `in-progress/` and is **resumed first on the next run, on top of prior
progress**, not restarted:

- The worktree `auto/<slug>` with its existing commits and uncommitted edits is
  **reused**, not recreated.
- A per-step checkpoint (`logs/<slug>/state.json`, written after each step:
  `build` done → `reviewed` round N → `fixed` round N) drives resume: a committed
  build is skipped; the review loop continues from the interrupted round; if the
  interruption landed **between review and fix**, the already-written review
  reports are reused and it goes straight to the fix.
- The checkpoint is trusted **only if the worktree is actually intact**. If the
  worktree vanished or moved to another branch, the runner recreates it clean
  from `main`, discards the stale checkpoint, and runs from scratch.

## Isolation & safety

- Each task runs in its own worktree at `../<repo>-worktrees/<slug>` on branch
  `auto/<slug>` (see `docs/ai/recipes/git-worktree.md`). The runner never touches
  `main` and never pushes. Worst case is a throwaway commit on a throwaway branch
  you choose not to keep.
- Build/fix agents run with permissions bypassed (`--dangerously-skip-permissions`
  or equivalent) so they can run commands unattended — **only run this in a repo
  you trust.**
- **Review passes are read-only** (Codex `-s read-only`; the Claude reviewer with
  `--disallowedTools "Edit Write NotebookEdit"`).
- **Network is on** (agents need the model API) — this is not a hard sandbox. For
  strict isolation, run the whole thing in a devcontainer/VM. Filesystem and
  network are constrained via `night-runner/sandbox.settings.json` (see
  `docs/ai/recipes/sandboxes.md`).
- Agents see the whole repo. Keep secrets out of the tree (`.env` in
  `.gitignore`) and **never put secrets in a brief** — the agent reads it whole.

## Commit hooks: `--no-verify`

WIP commits on the throwaway `auto/<slug>` branch are made with `--no-verify`.
A heavy pre-commit hook (full CI + install on every commit) is wrong for a
tight commit→review→fix loop in a worktree with a symlinked/`install`ed
dependency dir. The quality gate is held by the agents themselves (`<check>` in
build/fix + the review loop). **Your full hook fires when you commit the result
into `main` yourself** — that is the right place for the gate.

## Rate limits

On a limit-shaped CLI response (`rate limit`, `429`, `overloaded`, `resets at`),
sleep (`RATE_SLEEP_MS`, default 1h) and retry the step; if the limit lifts during
the sleep the step just continues in the same worktree, nothing is lost. After
`RATE_ATTEMPTS` attempts (default 6) the runner stops and leaves the current brief
in `in-progress/` to resume next run.

- On a **plan** limit, wait and retry — do not silently downgrade the model.
- On a **correctness-review** limit, an optional fallback lets the builder model
  do the correctness pass instead, with a note in the report that it was not the
  dedicated reviewer.

## Applying results

Nothing is destroyed until you say so. Review each worktree's diff
(`git diff main...HEAD` — three-dot, see the worktree recipe), then apply the
ones you want into `main` as unstaged changes and commit them yourself. A separate
cleanup step removes the worktree, branch, brief, and logs once you've accepted
the change.

## Suggested config knobs

Expose these as env vars in your runner (defaults shown):

| Var                   | Default   | Purpose                              |
| --------------------- | --------- | ------------------------------------ |
| `PLAN_MODEL`          | `gpt-5.5` | planner (Codex)                      |
| `BUILD_MODEL`         | `opus`    | build / fix (Claude)                 |
| `CORRECTNESS_MODEL`   | `gpt-5.5` | correctness review (Codex)           |
| `DESIGN_MODEL`        | `opus`    | design review (Claude)              |
| `MAX_ROUNDS`          | `3`       | max review→fix rounds                |
| `RATE_SLEEP_MS`       | `3600000` | sleep on rate limit (1h)             |
| `RATE_ATTEMPTS`       | `6`       | attempts before stopping             |
| `AGENT_TIMEOUT_MS`    | `5400000` | per-agent call timeout (90m)         |

Model IDs are editable defaults — see `docs/ai/commands/choose-model.md` and
`MODEL_PRESETS.md`.

## Limitations

- Briefs are processed one at a time, sequentially.
- A brief that changes dependencies (`package.json`/lockfile) may break the
  worktree's dependency setup — finish those by hand.
- The runner produces local worktrees + branches only; it does not push or open
  PRs.
