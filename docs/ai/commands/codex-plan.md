# codex-plan

The current host orchestrator closes material questions, asks the read-only Codex
planner for the plan, reconciles it, and writes the artifact. Codex returns
Markdown and never writes repository files.

## Roles

- **Host orchestrator:** context, user-question loop, role/effort resolution,
  reconciliation, artifact write, and human gate.
- **Codex planner:** plan content according to `docs/ai/skills/plan.md`.

Read `.agent-workflow-kit/config.conf`, active profiles, and
`docs/ai/agents/cli.md` first.

## Process

1. **Context:** inspect the task, affected code, project rules, and applicable
   profiles.
2. **Questions:** collect unresolved red flags through
   `docs/ai/skills/implementation-clarify.md`. Optionally ask Codex for additional
   questions. Answer discoverable questions from the repository and bring the
   remaining ones to the user in one host-native batch.
3. **Role/effort:** use `PLANNER_MODEL` and `DEFAULT_EFFORT`; raise to workflow
   `max` only when risk/uncertainty justifies it, mapping Codex through
   `CODEX_MAX_EFFORT`.
4. **Plan call:** invoke Codex read-only per `docs/ai/agents/cli.md`. Pass the task,
   repository evidence, settled answers, active profiles, and
   `docs/ai/skills/plan.md`.
5. **Reconcile:** verify scope, files, decisions, assumptions, and checks. Return
   concrete issues to Codex until the result converges; do not silently rewrite
   plan content yourself.
6. **Artifact:** the host writes
   `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`, then returns its path, a 3-6 point
   summary, assumptions, and remaining questions.

If the host lacks a user-question UI, ask in normal chat. If it lacks background
execution, run the same review calls sequentially and disclose that; semantics do
not depend on a vendor-specific tool name.

## Status lines

```text
Clarification: no red flags -> accepted defaults [X, Y]
Plan role: model <configured value>, effort <workflow -> host value> - <why>
```
