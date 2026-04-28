---
description: Propose durable rule or workflow improvements after a useful session
---

Review the full chat context. Propose only durable improvements worth committing. Do not apply changes automatically.

## Filter

Suggest a change only if it:

1. will likely repeat in future work;
2. is specific enough for an agent to follow;
3. does not duplicate existing rules or docs;
4. is not a one-off decision or temporary preference;
5. saves more complexity than it adds.

If nothing is worth preserving, answer: `Nothing to preserve`.

## Targets

| Target | Use For |
| --- | --- |
| `CLAUDE.md` | Durable team instructions. Keep it under 200 lines. |
| `.claude/rules/*.md` | Modular or path-scoped invariants. |
| `.claude/skills/*` or `.claude/commands/*` | Reusable workflows and slash commands. |
| `README.md` or existing `docs/*.md` | Recipes and checklists. |

## Output

For each suggestion, include:

- action: add, replace, delete, or compress;
- target file;
- reason;
- draft text ready to paste.

Return at most three suggestions.
