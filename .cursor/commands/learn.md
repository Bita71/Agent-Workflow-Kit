# learn

Review the full chat context and propose only durable improvements worth committing to the repository. Do not apply changes automatically.

## Usefulness Filter

Suggest a change only if it:

1. will likely repeat in future work;
2. is specific enough for an agent to follow;
3. does not duplicate existing rules or docs;
4. is not a one-off decision or temporary preference;
5. saves more complexity than it adds.

If nothing is worth preserving, answer: `Nothing to preserve`.

## Good Targets

| Target | Use For |
| --- | --- |
| `.cursor/rules/*.mdc` | Durable invariants, prohibitions, required checks. |
| `AGENTS.md` | Workflow map, new commands, agent roles. |
| `README.md` or existing `docs/*.md` | Recipes, checklists, repeated procedures. |

## Output

For each suggestion, include:

- action: add, replace, delete, or compress;
- target file;
- reason;
- draft text ready to paste.

Return at most three suggestions.
