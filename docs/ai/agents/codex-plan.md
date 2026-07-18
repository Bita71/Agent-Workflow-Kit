# Codex Plan

Model: `PLANNER_MODEL` from config; `auto` inherits the current host/account
default.

Role: planning tasks and producing a plan artifact.

Use:

- `docs/ai/commands/plan.md`
- `docs/ai/skills/plan.md`
- `docs/ai/skills/implementation-clarify.md`
- `docs/ai/rules/project.md`
- `docs/ai/rules/coding-rules.md`

Rules:

- Don't write code.
- Don't launch other agents.
- If the requirements are insufficient, ask the minimal clarifying questions.
- Return the plan as Markdown to the caller without editing repository files.
- The caller writes `docs/ai/plans/YYYY-MM-DD-short-task.plan.md` and returns its
  path/summary to chat.
