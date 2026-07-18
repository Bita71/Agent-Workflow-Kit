# AI Audit: reviewing rules, skills, agents, commands

## Why

`/learn` captures knowledge from one specific session. An AI audit is a separate,
periodic review of the project's AI surface: find duplicates, stale instructions,
overly heavy always-applied rules, and drift between rules / skills / commands.

## When to run

- After a series of changes in `docs/ai/*` or in the adapters (`.cursor/*`,
  `.claude/*`, `.codex/*`, `AGENTS.md`, `CLAUDE.md`).
- When an agent starts confusing old and new workflows.
- Before adding a new rule, skill, command, or subagent.
- After `/learn`, when several suggestions have piled up and you need to decide
  where they belong.

## What to check

1. **Inventory**

   Source of truth (`docs/ai/*`):
   - `docs/ai/README.md` — the AI workflow map.
   - `docs/ai/rules/*.md`, `docs/ai/skills/*.md`, `docs/ai/commands/*.md`,
     `docs/ai/agents/*.md`, `docs/ai/recipes/*.md`.

   Adapters (should only reference the source of truth, not duplicate its content):
   - `AGENTS.md` — Codex entry point.
   - `.codex/agents/*` — Codex subagents.
   - `CLAUDE.md` — Claude entry point.
   - `.claude/commands/*`, `.claude/agents/*`, `.claude/skills/*` — Claude commands,
     subagents, and skills.
   - `.cursor/commands/*`, `.cursor/agents/*`, `.cursor/skills/*`, `.cursor/rules/*`
     — Cursor commands, subagents, skills, and rules.

2. **Duplicates and stale files**
   - Unresolved merge conflicts (`<<<<<<<`, `=======`, `>>>>>>>`) in any
     rules/skills/commands/agents — a critical blocker, fix it first.
   - Old folders or names left after renames (e.g. `plan`/`build`/… without the
     `skill-` prefix, `*-impl` duplicates).
   - Identical rules across `docs/ai/rules`, adapters, skills, and recipes — an
     adapter should contain only a "Source of truth: …" reference, no copy of the
     text.
   - Commands that describe a workflow already moved into a skill.
   - Files in `docs/ai/agents/*` or `docs/ai/commands/*` not mentioned in
     `docs/ai/README.md` (or, conversely, links in the README to files that do not
     exist).
   - Adapters referencing deleted source-of-truth files.
   - A general rule or principle (in `rules`/`skills`) that references a specific
     narrow file (an agent/command) as its justification — remove the link or state
     the rule self-sufficiently. Downward links to a specific case create false
     coupling; dependencies should point only from the specific to the general.

3. **Context budget**
   - Move large or narrow rules into `globs` / an on-demand rule / a skill / a recipe.
   - Keep `AGENTS.md`, `CLAUDE.md`, and the Cursor rules as thin adapter maps, not a
     second set of rules.
   - Keep `.claude/commands/*` and `.cursor/commands/*` as short entry points into
     `docs/ai/commands/*`, with no copy of the workflow.

4. **Rule placement**
   - Repeated across several skills/recipes → a candidate for `docs/ai/rules`.
   - Belongs to one workflow → keep it in the skill (`docs/ai/skills/*`).
   - Describes "how to do X" → a recipe (`docs/ai/recipes/*`).
   - Only a user entry point → a command (`docs/ai/commands/*` + the adapters that
     need it).
   - An agent's role (model, boundaries) → `docs/ai/agents/*` + adapters
     (`.claude/agents/*`, `.cursor/agents/*`, `.codex/agents/*`).

5. **Adapter consistency**
   - Every command in `docs/ai/commands/*` has adapters where it is actually used,
     and no extras — different tools have different roles (see `CLAUDE.md`,
     `AGENTS.md`).
   - Every agent in `docs/ai/agents/*` is mentioned in `docs/ai/README.md` and has
     an adapter for the tool that runs it.
   - `CLAUDE.md`, `AGENTS.md`, and the Cursor rules contain no links to deleted
     workflows.

## Report format

```markdown
## AI Audit

### Remove

- `[path]` — why it is stale or duplicates another place.

### Compress / move

- `[path]` → `[target]` — what exactly to move and why.

### Keep

- `[path]` — why this is the right place.

### Add

- `[path]` — only if there is a repeatable gap not covered by rules/skills/recipes.
```
