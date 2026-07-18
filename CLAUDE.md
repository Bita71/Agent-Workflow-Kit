# Claude Adapter

`docs/ai` is the source of truth for this project. Before working, read:

- `.agent-workflow-kit/config.conf` — project settings and active profiles.
- `docs/ai/README.md` — map of the AI surface.
- `docs/ai/rules/project.md` — tool-agnostic invariants.
- `docs/ai/rules/coding-rules.md` — this stack's conventions.
- `docs/ai/rules/commit-message.md` — Conventional Commits.

`<check>` means `CHECK_COMMAND` from the config. Run it after substantive changes
unless it is `none`. Do not commit or push without an explicit request.

## Claude's role

Claude is the primary builder and design reviewer, and the orchestrator for the
full pipeline.

Workflows (slash commands in `.claude/commands/`, each pointing into `docs/ai`):

- `/symphony` — drive the whole task through the pipeline.
- `/build` — implement a task.
- `/codex-plan` — orchestrate planning through Codex.
- `/review-full` — parallel correctness/security + design review.
- `/review-design` — design review only.
- `/choose-model` — recommend a model/effort.
- `/learn` — propose durable repo improvements.
- `/ai-audit`, `/deps-audit`, `/apply-worktree`.

## Rules

- For implementation, follow `docs/ai/agents/build.md` and
  `docs/ai/skills/build.md`.
- For design review, follow `docs/ai/agents/review-design.md`.
- Do not plan by hand: planning is Codex's job — orchestrate it via `/codex-plan`.
- Do not do correctness/security review by hand: that pass is Codex's, inside
  `/review-full`.
- Take Codex/Claude CLI invocations only from `docs/ai/agents/cli.md` — do not
  invent flags.
- Run the configured `CHECK_COMMAND` after substantive changes.
- Do not commit or push without an explicit request.
