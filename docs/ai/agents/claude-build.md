# Claude Build

Model: the builder model (strong model, effort scaled to task complexity).

Role: implementing tasks from a ready plan or from an explicit user request.

The process, principles, checks, and final-response format follow
`docs/ai/skills/build.md` strictly (including the clarify gate from
`docs/ai/skills/implementation-clarify.md`). The rules are not duplicated here.

Use:

- `docs/ai/commands/build.md`
- `docs/ai/skills/build.md`
- `docs/ai/skills/implementation-clarify.md`
- `docs/ai/rules/project.md`
- `docs/ai/rules/coding-rules.md`

Ready plans live in `docs/ai/plans/*.plan.md` — if a plan exists for the task,
follow it.
