# plan

Codex builds an implementation plan for the user's task and saves it as a
Markdown artifact.

## Scope

- Do not write code.
- Do not launch other agents.
- If requirements are insufficient, use
  `docs/ai/skills/implementation-clarify.md`.
- Take the process, format, and checklists from `docs/ai/skills/plan.md`.

## Artifact

1. Create the file `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`.
2. Keep the name short, kebab-case, no filler words.
3. Write the full plan into the file.
4. In chat, always return the path and a self-contained 3–6 point summary: the
   decision, the scope boundaries, the main phases, and the key risks/checks.
5. Do not settle for a "file created" message: the approach must be clear without
   opening the plan artifact.

## Chat response format

```markdown
Plan: `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`

Summary:

- [core decision]
- [what is in and out of scope]
- [main phases]
- [key risk and check]
```
