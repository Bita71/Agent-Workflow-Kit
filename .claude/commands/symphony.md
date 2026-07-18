# symphony

Drive the whole task through the full pipeline as the orchestrator.

Follow `docs/ai/commands/symphony.md` exactly: clarify → plan (Codex) → build
(subagent) → verify against the plan → parallel review → triage → fix loop → done,
with human gates and a resumable run file.

Supporting docs the command relies on:

- `docs/ai/agents/cli.md` — canonical CLI calls (do not invent flags)
- `docs/ai/commands/codex-plan.md`, `docs/ai/commands/review-full.md`
- `docs/ai/commands/choose-model.md`
- `docs/ai/recipes/git-worktree.md`
- `docs/ai/rules/commit-message.md`, `docs/ai/runs/README.md`
