# AI Workflow

`docs/ai` is the shared source of truth for AI rules, commands, skills, agent
roles, and artifacts. Every tool (Claude Code, Codex, Cursor) points here through
a thin adapter instead of keeping its own copy of the logic. Edit the logic once,
in `docs/ai`; the adapters just reference it.

`<check>` throughout these docs means **your repository's standard verification
command** — lint + typecheck + tests (e.g. `npm run check`, `yarn ai:check`).
Define it once in `CLAUDE.md` / `AGENTS.md` and wire it up.

## Rules

- `docs/ai/rules/project.md` — tool-agnostic invariants: scope, clarify, safety,
  verification.
- `docs/ai/rules/coding-rules.md` — **template**: your stack's conventions
  (architecture boundaries, types, UI/i18n, styling, code style).
- `docs/ai/rules/commit-message.md` — Conventional Commits.
- `docs/ai/rules/testing.md` — what to cover with tests and how.

## Skills

- `docs/ai/skills/plan.md` — planning a task.
- `docs/ai/skills/build.md` — implementing a task.
- `docs/ai/skills/implementation-clarify.md` — clarify gate before work.
- `docs/ai/skills/review-correctness.md` — review for bugs and edge cases.
- `docs/ai/skills/review-design.md` — review architecture, boundaries, UX,
  performance, simplification.
- `docs/ai/skills/review-security.md` — security review driven by risk signals.

## Commands

- `docs/ai/commands/symphony.md` — one orchestrator drives the whole task through
  the full pipeline: clarify → plan → build → verify → review → triage → fix loop,
  with human gates and a resumable run file.
- `docs/ai/commands/plan.md` — the planner writes a `.plan.md` directly.
- `docs/ai/commands/codex-plan.md` — Claude orchestrates planning through the
  Codex CLI: questions, plan, reconciliation, gate.
- `docs/ai/commands/build.md` — implement a task.
- `docs/ai/commands/review-full.md` — orchestrate a parallel review: Codex
  correctness/security ∥ strong-model design, merged into one deduplicated report.
- `docs/ai/commands/review-design.md` — design review.
- `docs/ai/commands/choose-model.md` — recommend a model/effort for the work.
- `docs/ai/commands/ai-audit.md` — audit the project's AI surface.
- `docs/ai/commands/deps-audit.md` — runtime dependency audit.
- `docs/ai/commands/learn.md` — propose what to persist in the repo after a session.

## Agent Roles

- `docs/ai/agents/cli.md` — canonical CLI invocations for Codex/Claude used by the
  orchestrating commands and runners. **Do not invent flags — take them from here.**
- `docs/ai/agents/codex-plan.md` — the planner.
- `docs/ai/agents/claude-build.md` — the builder.
- `docs/ai/agents/review-correctness.md` — correctness reviewer.
- `docs/ai/agents/review-security.md` — security reviewer.
- `docs/ai/agents/review-design.md` — design reviewer.

## Artifacts

- `docs/ai/plans/` — plans: `YYYY-MM-DD-short-task.plan.md`.
- `docs/ai/reviews/` — reviews: `YYYY-MM-DD-short-task.review.md`.
- `docs/ai/runs/` — `/symphony` run state: `YYYY-MM-DD-short-task.symphony.md`.

## Adapters

- `CLAUDE.md` + `.claude/` — Claude Code: native commands and a design-review
  subagent that point into `docs/ai`.
- `AGENTS.md` + `.agents/skills/*/SKILL.md` + `.codex/` — Codex: repo instructions,
  repo-scoped skills, and custom subagents. Codex runs workflows via text triggers
  and skills, not project slash commands.
- `.cursor/` — Cursor: rules, commands, and skills that reference `docs/ai`.

## Recipes

- `docs/ai/recipes/git-worktree.md` — isolated git worktree workflow (create, apply,
  delete) and its many pitfalls.
- `docs/ai/recipes/verification.md` — extra verification pass after implementation.
- `docs/ai/recipes/ai-audit.md` — reviewing the rules/skills/agents/commands surface.
- `docs/ai/recipes/night-runner.md` — the unattended two-phase batch runner pattern.
- `docs/ai/recipes/night-runner-briefs.md` — how to write briefs for the runner.
- `docs/ai/recipes/sandboxes.md` — the three sandbox layers and how they interact.
