# Codex Adapter

`docs/ai` is the source of truth for rules, skills, commands, agent roles, and
artifacts. Before working, read:

- `.agent-workflow-kit/config.conf` — project settings, active profiles, model
  roles, check command, and base ref.
- `docs/ai/README.md` — map of the AI surface.
- `docs/ai/rules/project.md` — tool-agnostic invariants.
- `docs/ai/rules/coding-rules.md` — this stack's conventions.
- `docs/ai/rules/commit-message.md` — Conventional Commits.

`<check>` means `CHECK_COMMAND` from the config. Run it after substantive changes
unless it is explicitly `none`. Do not commit or push without an explicit request.

## What Codex picks up

- `AGENTS.md` — project instructions.
- `.agents/skills/*/SKILL.md` — repo-scoped skills.
- `.codex/agents/*.toml` — repo-scoped custom subagents.
- `.codex/config.toml` — base Codex settings (sandbox, network).

## Text triggers

Codex does not use the project slash commands in `.claude/commands`. When the user
writes a text trigger or invokes a skill via `$...`, run the matching workflow:

| Trigger                                    | Workflow                           |
| ------------------------------------------ | ---------------------------------- |
| `codex plan`, `$skill-plan`                | `docs/ai/commands/plan.md`         |
| `codex review`, `$skill-review-correctness`| `docs/ai/commands/review-full.md`  |
| `codex choose-model`, `$skill-choose-model`| `docs/ai/commands/choose-model.md` |
| `codex ai-audit`, `$skill-ai-audit`        | `docs/ai/commands/ai-audit.md`     |
| `codex deps-audit`, `$skill-deps-audit`    | `docs/ai/commands/deps-audit.md`   |
| `codex learn`, `$skill-learn`              | `docs/ai/commands/learn.md`        |

If the user writes `/review`, treat it as a possible native Codex command, not a
project workflow. The project full review is orchestrated by a supported host via
`review-full`;
Codex performs the correctness/security passes inside it, per
`docs/ai/skills/review-correctness.md` and `docs/ai/skills/review-security.md`.

## Codex roles

- Planning: `docs/ai/agents/codex-plan.md`.
- Correctness review: `docs/ai/agents/review-correctness.md`.
- Security review: `docs/ai/agents/review-security.md`.
- Custom subagents: `.codex/agents/codex-plan.toml`,
  `.codex/agents/review-correctness.toml`, `.codex/agents/review-security.toml`,
  `.codex/agents/review-design.toml`.
- Canonical CLI invocations: `docs/ai/agents/cli.md` — do not invent flags.

## Artifacts

- Write plans to `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`.
- Write reviews to `docs/ai/reviews/YYYY-MM-DD-short-task.review.md`.
- Return a short summary and the file path to chat.

## Model policy

Resolve model roles and effort through `.agent-workflow-kit/config.conf` and
`docs/ai/commands/choose-model.md`. Do not pin model IDs in this adapter.
