# Plans

Implementation plans are written here as artifacts of the multi-agent workflow.

Filename format: `YYYY-MM-DD-short-task.plan.md`.

The planner creates the plan per `docs/ai/commands/plan.md` and
`docs/ai/skills/plan.md`. Claude orchestrates planning through `/codex-plan`
(`docs/ai/commands/codex-plan.md`): the question loop, running the planner,
reconciliation, and writing the artifact. A short summary and the file path are
returned to chat.
