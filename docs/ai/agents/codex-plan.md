# Codex Plan

Model: `gpt-5.5`.

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
- Write the plan to `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`.
- Return a short summary and the file path to chat.
