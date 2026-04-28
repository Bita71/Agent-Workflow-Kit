# Project Instructions

This project uses an agent workflow with a plan, build, review, verify loop.

## Core Workflow

```text
plan -> build -> review -> manual fixes -> verify
```

## Operating Rules

- Keep changes narrow and tied to the user's request.
- Read relevant files before editing.
- Ask only blocking questions; if the task is clear, proceed.
- Do not add dependencies, commit, or push unless explicitly requested.
- Prefer existing project patterns over new abstractions.
- Preserve user changes in a dirty working tree.
- After any code change, invoke the `verifier` subagent.

## Slash Commands

| Command | Purpose |
| --- | --- |
| `/plan` | Plan via the `plan-gpt` and (on escalation) `plan-claude` subagents. |
| `/plan-manual` | Plan in the current chat. |
| `/build` | Route to one builder subagent, then verify. |
| `/build-manual` | Implement in the current chat, then verify. |
| `/review` | Run `review-correctness` and `review-design` in parallel. |
| `/verify` | Run the `verifier` subagent. |
| `/learn` | Propose durable workflow or rule improvements. |

## Subagents

See `.claude/agents/*.md` for roles, tool access, and usage criteria.

## Skills

See `.claude/skills/*` for the planning, build-routing, and clarify workflows.

## Rules

See `.claude/rules/*` for coding invariants. Extend with project-specific rules.

## Repository Commands

Replace this section with your repository's actual commands:

```bash
# build
# test
# lint
# typecheck
# full ci
```

## Architecture Notes

Replace this section with a short map of your codebase: key modules, public APIs, tests, data flow. Keep this file under 200 lines.
