# night-runner

Config templates for the unattended two-phase batch runner. The runner itself is
a thin loop you wire to your task runner — the full pattern, lifecycle, recovery,
limits, and safety model are documented in
[`docs/ai/recipes/night-runner.md`](../docs/ai/recipes/night-runner.md).

## What's here

- `sandbox.settings.json` — filesystem + network sandbox passed to the Claude CLI
  via `--settings` for unattended build/fix runs. The installer generates its
  network allowlist from `RUNNER_NETWORK_ALLOWED_DOMAINS`; extend `denyRead` for
  your setup and never loosen the write scope past `./`.
  Explained in [`docs/ai/recipes/sandboxes.md`](../docs/ai/recipes/sandboxes.md).
- `briefs/TEMPLATE.md` — starting point for a task brief. Copy it into
  `briefs/new/`. How to write good briefs:
  [`docs/ai/recipes/night-runner-briefs.md`](../docs/ai/recipes/night-runner-briefs.md).

## Flow at a glance

```text
briefs/new/  → plan   → briefs/planned/   (planner writes logs/<slug>/plan.md)
             ↑ you read plans, fix wrong assumptions
briefs/planned/ → build → review → fix → briefs/done/
                                       ↘ briefs/manual-review/  (round limit hit)
```

- **Phase 1 — plan:** planner model (Codex, read-only) builds a self-contained plan
  per brief with a "Questions and assumptions" section. Follows
  `docs/ai/skills/plan.md`.
- **You** read the plans and fix any brief whose assumptions are wrong.
- **Phase 2 — build + review + fix:** strong builder implements the plan in an
  isolated worktree (`docs/ai/recipes/git-worktree.md`), correctness + design
  reviewers run over the frozen commit, the builder fixes Critical/Required
  findings, looping until clean or the round cap.

## Build your runner

The loop maps 1:1 onto the kit's existing pieces — you only orchestrate them:

- CLI invocations for every agent call: `docs/ai/agents/cli.md`.
- Roles: planner `docs/ai/agents/codex-plan.md`, builder
  `docs/ai/agents/build.md`, reviewers `docs/ai/agents/review-*.md`.
- Config knobs (models, round cap, rate-limit sleep/attempts, timeouts) and the
  full safety model: `docs/ai/recipes/night-runner.md`.

Briefs are not committed to the repo — add `night-runner/briefs/new/`,
`planned/`, `in-progress/`, `done/`, `manual-review/`, and `night-runner/logs/`
to `.gitignore`.
